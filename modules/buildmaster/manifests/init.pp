# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster class
# include this in your node to have all the base requirements for running a
# buildbot master installed
# To setup a particular instance of a buildbot master, see
# buildmaster::buildbot_master
#
# buildmaster requires that $num_masters be set on the node prior to including this class
#
# TODO: move $libdir stuff into template?
# TODO: you still have to set up ssh keys!
# TODO: determine num_masters from json (bug 647374)
class buildmaster {
    # TODO: port releng module
    #include releng::master
    #include secrets
    include buildmaster::queue
    include buildmaster::settings
    $master_basedir = $buildmaster::settings::master_basedir
    $clone_config_dir = $buildmaster::settings::master_basedir
    if $num_masters == '' {
        fail("you must set num_masters")
    }
    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }
    sysctl::value {
        "net.ipv4.tcp_keepalive_time":
            value => "240"
    }
    file {
        "${buildmaster::settings::lock_dir}":
            ensure => directory,
            owner => $users::builder::group,
            group => $users::builder::username;
    }
}
