# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ganglia {
    include ::config
    if $::config::ganglia_config_class == "" {
        # No Ganglia Config defined, don't install
    } else {
        include packages::ganglia
        include users::root

        class {
            $::config::ganglia_config_class:
                ;
        }
        
        file {
            "/etc/ganglia":
                ensure => directory,
                owner => "root",
                group => "$::users::root::group",
                mode => 644;
        }
        
        service {
            gmond:
                require => File["/etc/ganglia/gmond.conf"],
                enable => true,
                ensure => running;
        }
    }
}
