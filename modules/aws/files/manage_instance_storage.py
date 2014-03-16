#!/usr/bin/env python
import urllib2
import urlparse
import time
import logging
import json
import os
from subprocess import check_call, CalledProcessError, STDOUT

devnull = open(os.devnull, 'w')


log = logging.getLogger(__name__)

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"


def get_aws_metadata(key):
    url = urlparse.urljoin(AWS_METADATA_URL, key)
    max_tries = 3
    for _ in range(max_tries):
        log.debug("Fetching %s", url)
        try:
            return urllib2.urlopen(url, timeout=1).read()
        except urllib2.URLError:
            if _ < max_tries - 1:
                log.debug("failed to fetch %s; sleeping and retrying", url, exc_info=True)
                time.sleep(1)
                continue
            return None


def run_cmd(cmd, cwd=None, raise_on_error=True, quiet=True):
    if not cwd:
	cwd = os.getcwd()
    log.info("Running %s in %s", cmd, cwd)
    try:
	if quiet:
	    stdout = devnull
	else:
	    stdout = None

	check_call(cmd, cwd=cwd, stdout=stdout, stderr=None)
	return True
    except CalledProcessError:
	if raise_on_error:
	    raise
	return False


def get_ephemeral_devices():
    block_devices = get_aws_metadata("block-device-mapping/").split("\n")
    names = [b for b in block_devices if b.startswith("ephemeral")]
    retval = []
    for n in names:
	device = get_aws_metadata("block-device-mapping/%s" % n)
	device = "/dev/%s" % device
	if not os.path.exists(device):
	    device = aws2xen(device)
	if os.path.exists(device):
	    retval.append(device)
	else:
	    log.warn("%s doesn't exist", device)
    return retval


def aws2xen(s):
    "Converts AWS device names (e.g. /dev/sdb) to xen block device names (e.g. /dev/xvdb)"
    return s.replace("/s", "/xv")


def format(device):
    run_cmd(['mkfs.ext4', device])


def lvmjoin(devices):
    "Creates a single lvm volume from a list of block devices"
    for d in devices:
	if not run_cmd(['pvdisplay', d], raise_on_error=False):
	    run_cmd(['dd', 'if=/dev/zero', 'of=%s' % d, 'bs=512', 'count=1'])
	    run_cmd(['pvcreate', '-ff', '-y', d])

    vg_name = 'vg'
    lv_name = 'local'
    if not run_cmd(['vgdisplay', vg_name], raise_on_error=False):
	run_cmd(['vgcreate', vg_name] + devices)
    lv_path = "/dev/mapper/%s-%s" % (vg_name, lv_name)
    if not run_cmd(['lvdisplay', lv_path], raise_on_error=False):
	run_cmd(['lvcreate', '-l', '100%VG', '--name', lv_name, vg_name])
	format(lv_path)
    return lv_path


def main():
    logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
    devices = get_ephemeral_devices()
    if len(devices) > 1:
	device = lvmjoin(devices)
    else:
	device = devices[0]
	# TODO: Check if it's already formatted
	format(device)
    print "Got", device

    # TODO: mount these on boot; modify fstab


if __name__ == '__main__':
    main()
