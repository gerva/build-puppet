# buildmaster::buildmaster::settings::queue class
# sets up buildmaster::settings::queue processors for pulse, commands, etc.

class buildmaster::queue {
    include buildmaster::settings

    file {
        "${buildmaster::settings::queue_dir}":
            ensure => "directory",
            owner => $user::builder::username,
            group => $user::builder::username;
        "/etc/init.d/command_runner":
            content => template("buildmaster/command_runner.initd.erb"),
            notify => Service["command_runner"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/run_command_runner.sh":
            content => template("buildmaster/run_command_runner.sh.erb"),
            notify => Service["command_runner"],
            mode => 755;
        "/etc/nagios/nrpe.d/command_runner.cfg":
            content => template("buildmaster/command_runner.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644;
        "/etc/init.d/pulse_publisher":
            content => template("buildmaster/pulse_publisher.initd.erb"),
            notify => Service["pulse_publisher"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/run_pulse_publisher.sh":
            content => template("buildmaster/run_pulse_publisher.sh.erb"),
            notify => Service["pulse_publisher"],
            mode => 755;
        "${buildmaster::settings::queue_dir}/passwords.py":
            content => template("buildmaster/passwords.py.erb"),
            mode => 600,
            owner => $user::builder::username,
            group => $user::builder::username;
        "${nrpe::settings::nrpe_etcdir}/pulse_publisher.cfg":
            content => template("buildmaster/pulse_publisher.cfg.erb"),
            require => Package["nrpe"],
            notify => Class["nrpe::service"],
            mode => 644;
        "${nrpe::settings::nrpe_etcdir}/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            require => Package["nrpe"],
            notify => Class['nrpe::service'],
            mode => 644;
    }
    service {
        "command_runner":
            hasstatus => true,
            require => [
                File["/etc/init.d/command_runner"],
                File["${buildmaster::settings::queue_dir}/run_command_runner.sh"],
                ],
            enable => true,
            ensure => running;
        "pulse_publisher":
            hasstatus => true,
            require => [
                File["/etc/init.d/pulse_publisher"],
                File["${buildmaster::settings::queue_dir}/run_pulse_publisher.sh"],
                ],
            enable => true,
            ensure => running;
    }
}
