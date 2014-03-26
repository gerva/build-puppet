#!/usr/bin/env python
"""Manages the instance storage on aws"""

import urllib2
import urlparse
import time
import logging
import os
import json
from subprocess import check_call, CalledProcessError, check_output

devnull = open(os.devnull, 'w')


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
        stdout = devnull
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
    try:
        return check_output(cmd, cwd=cwd, stderr=None).splitlines()
    except CalledProcessError:
        if raise_on_error:
            raise
        return []


def get_ephemeral_devices():
    """Gets the list of ephemeral devices"""
    block_devices = get_aws_metadata("block-device-mapping/").split("\n")
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


def lvmjoin(devices):
    "Creates a single lvm volume from a list of block devices"
    for device in devices:
        if not run_cmd(['pvdisplay', device], raise_on_error=False):
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
    if len(devices) > 1:
        device = lvmjoin(devices)
    else:
        device = devices[0]
        format_device(device)
    log.debug("Got {0}".format(device))
    update_fstab(device, mount_point())


if __name__ == '__main__':
    main()
