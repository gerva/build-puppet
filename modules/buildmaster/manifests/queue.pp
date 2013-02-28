# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster::buildmaster::settings::queue class
# sets up buildmaster::settings::queue processors for pulse, commands, etc.

class buildmaster::queue {
    include buildmaster::settings
    include users::builder
    include packages::mozilla::python27

    file {
        "/etc/init.d/command_runner":
            content => template("buildmaster/command_runner.initd.erb"),
            notify => Service["command_runner"],
            mode => 755;
        "/etc/init.d/pulse_publisher":
            content => template("buildmaster/pulse_publisher.initd.erb"),
            notify => Service["pulse_publisher"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/run_command_runner.sh":
            require => Python::Virtualenv["$buildmaster::settings::queue_dir"],
            content => template("buildmaster/run_command_runner.sh.erb"),
            notify => Service["command_runner"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/run_pulse_publisher.sh":
            require => Python::Virtualenv["$buildmaster::settings::queue_dir"],
            content => template("buildmaster/run_pulse_publisher.sh.erb"),
            notify => Service["pulse_publisher"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/passwords.py":
            require => Python::Virtualenv["$buildmaster::settings::queue_dir"],
            content => template("buildmaster/passwords.py.erb"),
            mode => 600,
            owner => $users::builder::username,
            group => $users::builder::username;
    }
    service {
        "command_runner":
            hasstatus => true,
            require => [
                File["/etc/init.d/command_runner"],
                File["${buildmaster::settings::queue_dir}/run_command_runner.sh"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
        "pulse_publisher":
            hasstatus => true,
            require => [
                File["/etc/init.d/pulse_publisher"],
                File["${buildmaster::settings::queue_dir}/run_pulse_publisher.sh"],
                File["${buildmaster::settings::queue_dir}/passwords.py"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
    }

    python::virtualenv {
        "$buildmaster::settings::queue_dir":
            python => "${packages::mozilla::python27::python}",
            require => Class['packages::mozilla::python27'],
            user => $users::builder::username,
            group => $users::builder::group,
            packages => [
                "buildbot==0.8.4-pre-moz2",
                "mozillapulse==ad95569a089e",
                "carrot==0.10.7",
                "amqplib==0.6.1",
                "anyjson==0.3",
                "pytz==2011d",
            ];
    }

    nrpe::custom {
        "pulse_publisher.cfg":
            content => template("buildmaster/pulse_publisher.cfg.erb"),
    }

    nrpe::custom {
        "command_runner.cfg":
            content => template("buildmaster/command_runner.cfg.erb"),
    }

    buildmaster::repos {
        "clone-tools":
            hg_repo => "${buildmaster::settings::buildbot_tools_hg_repo}",
            dst_dir => "${buildmaster::settings::queue_dir}/tools";
    }

    exec {
        "install-tools":
            require => [ File["${buildmaster::settings::queue_dir}"],
                         Python::Virtualenv["$buildmaster::settings::queue_dir"],
                         Buildmaster::Repos["clone-tools"],
                       ],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop",
            cwd => "${buildmaster::settings::queue_dir}/tools",
            user => $users::builder::username,
            group => $users::builder::group;
    }
}
