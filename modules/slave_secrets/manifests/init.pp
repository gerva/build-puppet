# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets($ensure=present, $slave_type) {
    # check that the node-level variable is set
    if ($slave_trustlevel == '') {
        fail("No slave_trustlevel is set for this host; add that to your node definition")
    }

    # compare the existing trustlevel to the specified; if they're not the same, we're in trouble
    if ($existing_slave_trustlevel != '' and $existing_slave_trustlevel != $slave_trustlevel) {
        fail("This host used to have trust level ${existing_slave_trustlevel}, and cannot be changed to ${slave_trustlevel} without a reimage")
    }

    # set the on-disk trust level if it's not already defined
    $trustlevel_file = '/etc/slave-trustlevel'
    file {
        $trustlevel_file:
            content => $slave_trustlevel,
            replace => false,
            mode => filemode(0500);
    }

    # actually do the work of installing, or removing, secrets
    case $ensure {
        present: {
            class {
                'slave_secrets::ssh_keys':
                    slave_type => $slave_type;
            }
        }
        absent: {
            # ssh keys are purged by ssh::userconfig
        }
    }

    # only install the google API key on build slaves
    if ($slave_type == 'build') {
        class {
            'slave_secrets::google_api_key':
                ensure => $ensure;
        }
    } else {
        class {
            'slave_secrets::google_api_key':
                ensure => absent;
        }
    }

    # install ceph credentials on build slaves
    if ($slave_type == 'build') {
        class {
            'slave_secrets::ceph_config':
                ensure => $ensure;
        }
    } else {
        class {
            'slave_secrets::ceph_config':
                ensure => absent;
        }
    }
}
