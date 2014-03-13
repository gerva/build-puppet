#!/usr/bin/env python
import urllib2
import urlparse
import time
import logging


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


def main():
    files = get_aws_metadata("block-device-mapping/").split("\n")
    print files


if __name__ == '__main__':
    main()
