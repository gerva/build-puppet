# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::common {
# This class disables unnecessary services common to both server and slave

    case $::operatingsystem {
        CentOS : {
            service {
                ['acpid', 'anacron', 'apmd', 'atd', 'auditd', 'autofs',
                'avahi-daemon', 'avahi-dnsconfd', 'bluetooth',
                'cups', 'cups-config-daemon', 'gpm', 'hidd', 'hplip', 'kudzu',
                'mcstrans', 'mdmonitor', 'pcscd', 'restorecond', 'rpcgssd',
                'rpcidmapd', 'sendmail', 'smartd', 'vncserver',
                'yum-updatesd'] :
                    enable => false,
                    ensure => stopped;
                'cpuspeed' :
                    enable => false;
            }
        }
        Ubuntu: {
            service {
                ['acpid', 'avahi-daemon', 'anacron', 'apport', 'modemmanager',
                 'whoopsie', 'cups', 'bluetooth', 'lightdm', 'network-manager']:
                    enable => false,
                    ensure => stopped;
            }
        }
        Darwin : {
            service {
                [
                    # bluetooth keyboard prompt
                    'com.apple.blued',
                    # periodic software update checks
                    'com.apple.softwareupdatecheck.initial', 'com.apple.softwareupdatecheck.periodic',
                ]:
                    enable => false,
                    ensure => stopped,
            }
            exec {
                "disable-indexing" :
                    command => "/usr/bin/mdutil -a -i off",
                    refreshonly => true ;

                "remove-index" :
                    command => "/usr/bin/mdutil -a -E",
                    refreshonly => true ;
            }
            file {
                "$settings::vardir/.puppet-indexing" :
                    content => "indexing-disabled",
                    notify => Exec["disable-indexing", "remove-index"] ;
            }
        }
    }
}
