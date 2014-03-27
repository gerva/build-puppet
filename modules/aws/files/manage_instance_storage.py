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
    log.info("Running %s in %s", cmd, cwd)
    stdout = None
    if quiet:
        stdout = open(os.devnull, 'w')
        check_call(cmd, cwd=cwd, stdout=stdout, stderr=None)
    try:
        check_call(cmd, cwd=cwd, stdout=stdout, stderr=None)
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
    log.info("Running %s in %s", cmd, cwd)
    # check_output is not avalilable in prod (python 2.6)
    # return check_output(cmd, cwd=cwd, stderr=None).splitlines()
    proc = Popen(cmd, cwd=cwd, stdout=PIPE)
    output, err = proc.communicate()
    retcode = proc.poll()
    if retcode and raise_on_error:
        log.debug('cmd: {0} returned {1} ({2})'.format(cmd, retcode, err))
        raise CalledProcessError
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
    blkid_cmd = ('blkid', '-o', 'udev', 'ext4', device)
    need_format = True
    for line in get_output_form_cmd(blkid_cmd):
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
    log.info("pvs output for device {0}: {1} ".format(device, output))
    if device in output:
        log.info("needs pvcreate -> True")
    else:
        log.info("needs pvcreate -> False")
    # just for testing...
    return False


def lvmjoin(devices):
    "Creates a single lvm volume from a list of block devices"
    for device in devices:
        if needs_pvcreate(device):
        #if not run_cmd(['pvdisplay', device], raise_on_error=False):
            run_cmd(['dd', 'if=/dev/zero', 'of=%s' % device,
                     'bs=512', 'count=1'])
            run_cmd(['pvcreate', '-ff', '-y', device])

    vg_name = 'vg'
    lv_name = 'local'
    if not run_cmd(['vgdisplay', vg_name], raise_on_error=False):
        run_cmd(['vgcreate', vg_name] + devices)
    lv_path = "/dev/mapper/%s-%s" % (vg_name, lv_name)
    if not run_cmd(['lvdisplay', lv_path], raise_on_error=False):
        run_cmd(['lvcreate', '-l', '100%VG', '--name', lv_name, vg_name])
        format_device(lv_path)
    return lv_path


def in_fstab(device):
    """check if device is in fstab"""
    is_in_fstab = False
    fstab = []
    with open('/etc/fstab', 'r') as f_in:
        fstab = f_in.readlines()

    for line in fstab:
        if device in line:
            log.debug("{0} already in /etc/fstab:").format(device)
            log.debug(line)
            is_in_fstab = True
            break
    return is_in_fstab


def update_fstab(device, mount_point):
    """Updates /etc/fstab if needed"""

    if in_fstab(device):
        # no need to update fstab
        return
    # example:
    # /dev/sda / ext4 defaults,noatime  1 1
    #
    new_device = '{0} {1} ext4 defaults,noatime 1 1'.format(device,
                                                            mount_point)
    log.debug('appending: {0} to /etc/fstab'.format(new_device))
    with open('/etc/fstab', 'a') as out_f:
        out_f.write(new_device)


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
            jacuzzi_data = json.load(data_file)
    except IOError:
        log.debug('{0} does not exist'.format(jacuzzi_metadata_file))
        return _mount_point

    if my_name() in jacuzzi_data:
        # hey I am a Jacuzzi!
        _mount_point = '/builds'
    return _mount_point


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
    log.debug("Got {0}".format(device))
    update_fstab(device, mount_point())


if __name__ == '__main__':
    main()
