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
# TODO: move $libdir stuff into template?
# TODO: you still have to set up ssh keys!
class buildmaster {
    # TODO: port releng module
    include buildmaster::queue
    include buildmaster::settings
    include tweaks::tcp_keepalive
    $master_basedir = $buildmaster::settings::master_basedir
    $clone_config_dir = $buildmaster::settings::master_basedir
    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }
    file {
        "${buildmaster::settings::lock_dir}":
            ensure => directory,
            owner => $users::builder::group,
            group => $users::builder::username;
        "/etc/nagios/nrpe.d/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"];
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600;
        "/etc/init.d/buildbot":
            source => "puppet:///modules/buildmaster/buildbot.initd",
            mode => 755;
        "/etc/default/buildbot.d/":
            ensure => directory,
            mode => 755,
            recurse => true,
            force => true;
    }
}
