# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class tftpd {
    include packages::xinetd
    include packages::tftp-server

    case $::operatingsystem {
        CentOS: {

            service {
                "xinetd":
                    require => Class["packages::xinetd"],
                    ensure  => running,
                    enable => true;
            }

            file {
                "/etc/xinetd.d/tftp":
                    ensure => file,
                    source => "puppet:///modules/tftpd/tftp",
                    notify => Service["xinetd"];
                "/var/lib/tftpboot":
                    ensure => directory;
                "/tftpboot":
                    ensure => link,
                    target => "/var/lib/tftpboot";
            }
        }
        default: {
            fail("Can't set up tftpd on this platform")
        }
    }
}
