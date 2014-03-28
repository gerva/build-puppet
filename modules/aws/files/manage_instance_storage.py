#!/usr/bin/env python
"""Manages the instance storage on aws"""

import urllib2
import urlparse
import time
import logging
import os
import json
from subprocess import check_call, CalledProcessError, Popen, PIPE


log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"


def get_aws_metadata(key):
    """Gets values form AWS_METADATA_URL"""
    url = urlparse.urljoin(AWS_METADATA_URL, key)
    max_tries = 3
    for _ in range(max_tries):
        log.debug("Fetching %s", url)
        try:
            return urllib2.urlopen(url, timeout=1).read()
        except urllib2.URLError:
            if _ < max_tries - 1:
                log.debug("failed to fetch %s; sleeping and retrying",
                          url, exc_info=True)
                time.sleep(1)
                continue
            return None


def run_cmd(cmd, cwd=None, raise_on_error=True, quiet=True):
    """A subprocess wrapper"""
    if not cwd:
        cwd = os.getcwd()
    log.debug("Running: %s cwd: %s", cmd, cwd)
    stdout = None
    stderr = open(os.devnull, 'w')
    if log.level == logging.DEBUG:
        # enable stderr only when we are in DEBUG mode
        stderr = None
    if quiet:
        stdout = open(os.devnull, 'w')
    try:
        check_call(cmd, cwd=cwd, stdout=stdout, stderr=stderr)
        return True
    except CalledProcessError:
        if raise_on_error:
            raise
        return False


def get_output_form_cmd(cmd, cwd=None, raise_on_error=True):
    """A subprocess wrapper but it returns the stdout"""
    # note this is a simple wrapper, do not try to run this function
    # if command produces a lot of output.
    if not cwd:
        cwd = os.getcwd()
    log.debug("Running %s cwd: %s", cmd, cwd)
    # check_output is not avalilable in prod (python 2.6)
    # return check_output(cmd, cwd=cwd, stderr=None).splitlines()
    log.debug("cmd: {0}; cwd={1}".format(cmd, cwd))
    proc = Popen(cmd, cwd=cwd, stdout=PIPE)
    output, err = proc.communicate()
    retcode = proc.poll()
    if retcode and raise_on_error:
        log.debug('cmd: {0} returned {1} ({2})'.format(cmd, retcode, err))
        raise CalledProcessError(retcode, cmd, output)
    return output


def get_ephemeral_devices():
    """Gets the list of ephemeral devices"""
    block_devices_mapping = get_aws_metadata("block-device-mapping/")
    if not block_devices_mapping:
        return []
    block_devices = block_devices_mapping.split("\n")
    names = [b for b in block_devices if b.startswith("ephemeral")]
    retval = []
    for name in names:
        device = get_aws_metadata("block-device-mapping/%s" % name)
        device = "/dev/%s" % device
        if not os.path.exists(device):
            device = aws2xen(device)
        if os.path.exists(device):
            retval.append(device)
        else:
            log.warn("%s doesn't exist", device)
    return retval


def aws2xen(device):
    """"Converts AWS device names (e.g. /dev/sdb)
    to xen block device names (e.g. /dev/xvdb)"""
    return device.replace("/s", "/xv")


def format_device(device):
    """formats the disk with ext4 fs if needed"""
    if is_mounted(device):
        log.debug('{0} is mounted: skipping formatting')
    blkid_cmd = ['blkid', '-o', 'udev', device]
    need_format = True
    output = get_output_form_cmd(cmd=blkid_cmd, raise_on_error=False)
    if output:
        for line in output.splitlines():
            if 'ID_FS_TYPE=ext4' in line:
                need_format = False
                log.info('{0} no need to format: {1}'.format(device, line))
                break
    if need_format:
        log.info('formatting {0}'.format(device))
        run_cmd(['mkfs.ext4', device])


def needs_pvcreate(device):
    """checks if pvcreate is needed"""
    output = get_output_form_cmd('pvs')
    log.debug("pvs output for device {0}: {1} ".format(device, output))
    for line in output.splitlines():
        if device in line:
            return False
    return True


def lvmjoin(devices):
    "Creates a single lvm volume from a list of block devices"
    for device in devices:
        if needs_pvcreate(device):
        #if not run_cmd(['pvdisplay', device], raise_on_error=False):
            log.info('clearing the partition table for {0}'.format(device))
            run_cmd(['dd', 'if=/dev/zero', 'of=%s' % device,
                     'bs=512', 'count=1'])
            log.info('creating a new physical volume for: {0}'.format(device))
            run_cmd(['pvcreate', '-ff', '-y', device])
    vg_name = 'vg'
    lv_name = 'local'
    if not run_cmd(['vgdisplay', vg_name], raise_on_error=False):
        log.info('creating a new volume group, {0} with {1}'.format(vg_name,
                                                                    devices))
        run_cmd(['vgcreate', vg_name] + devices)
    lv_path = "/dev/mapper/%s-%s" % (vg_name, lv_name)
    if not run_cmd(['lvdisplay', lv_path], raise_on_error=False):
        log.info('creating a new logical volume')
        run_cmd(['lvcreate', '-l', '100%VG', '--name', lv_name, vg_name])
        format_device(lv_path)
    return lv_path


def fstab_line(device):
    """check if device is in fstab"""
    is_fstab_line = False
    for line in read_fstab():
        if device in line:
            log.debug("{0} already in /etc/fstab:".format(device))
            log.debug(line)
            is_fstab_line = line
            break
    return is_fstab_line


def read_fstab():
    """"returns a list of lines in fstab"""
    with open('/etc/fstab', 'r') as f_in:
        return f_in.readlines()


def update_fstab(device, mount_point):
    """Updates /etc/fstab if needed"""
    # example:
    # /dev/sda / ext4 defaults,noatime  1 1
    new_fstab_line = '{0} {1} ext4 defaults,noatime 1 1\n'.format(device,
                                                                  mount_point)
    old_fstab_line = fstab_line(device)
    if old_fstab_line == new_fstab_line:
        # nothing to do..
        return
    # needs to be added
    if not old_fstab_line:
        with open('/etc/fstab', 'a') as out_f:
            out_f.write(new_fstab_line)
        return
    # just in case...
    log.debug(read_fstab())
    old_fstab = read_fstab()
    with open('/etc/fstab', 'w') as out_fstab:
        for line in old_fstab:
            out_fstab.write(line.replace(old_fstab_line, new_fstab_line))


def my_name():
    import socket
    return socket.gethostname().partition('.')[0]


def mount_point():
    """Checks if this machine is part of any jacuzzi pool"""
    jacuzzi_metadata_file = '/etc/jacuzzi_metadata.json'
    # default mount point
    _mount_point = '/mnt/instance_storage'
    try:
        with open(jacuzzi_metadata_file) as data_file:
            if json.load(data_file):
                # hey I am a Jacuzzi!
                _mount_point = '/builds'
    except IOError:
        log.debug('{0} does not exist'.format(jacuzzi_metadata_file))
    except TypeError:
        log.debug('{0} is empty'.format(jacuzzi_metadata_file))
    return _mount_point


def is_mounted(device):
    mount = get_output_form_cmd('mount')
    log.debug("mount: {0}".format(mount))
    for line in mount.splitlines():
        log.debug(line)
        if device in line:
            log.debug('device: {0} is mounted'.format(device))
            return True
    log.debug('device: {0} is not mounted'.format(device))
    return False


def mount(device):
    mount_p = mount_point()
    if not os.path.exists(mount_p):
        log.debug('Creating directory {0}'.format(mount_p))
        os.makedirs(mount_p)
    log.info('mounting {0}'.format(device))
    run_cmd(['mount', device])
    #run_cmd(['mount', device, mount_p])


def main():
    """Prepares the ephemeral devices"""
    logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
    devices = get_ephemeral_devices()
    if not devices:
        # no ephemeral devices, nothing to do, quit
        log.info('no ephemeral devices found')
        return
    if len(devices) > 1:
        log.info('found devices: {0}'.format(devices))
        device = lvmjoin(devices)
    else:
        device = devices[0]
        log.info('found device: {0}'.format(device))
        format_device(device)
    log.info("Got {0}".format(device))
    update_fstab(device, mount_point())
    if not is_mounted(device):
        mount(device)

if __name__ == '__main__':
    main()
