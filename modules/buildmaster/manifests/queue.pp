# buildmaster::queue class
# sets up queue processors for pulse, commands, etc.

class buildmaster::queue {
    include buildmaster::settings
#    include buildmaster::virtualenv

    $queue_venv_dir = "$buildmaster::settings::queue_venv_dir"


    file {
        "/etc/init.d/command_runner":
            content => template("buildmaster/command_runner.initd.erb"),
            notify => Service["command_runner"],
            mode => 755,
        "${queue_venv_dir}/run_command_runner.sh":
            content => template("buildmaster/run_command_runner.sh.erb"),
            notify => Service["command_runner"],
            mode => 755,
        "/etc/nagios/nrpe.d/command_runner.cfg":
            content => template("buildmaster/command_runner.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
        "/etc/init.d/pulse_publisher":
            content => template("buildmaster/pulse_publisher.initd.erb"),
            notify => Service["pulse_publisher"],
            mode => 755,
        "${queue_venv_dir}/run_pulse_publisher.sh":
            content => template("buildmaster/run_pulse_publisher.sh.erb"),
            notify => Service["pulse_publisher"],
            mode => 755,
        "${queue_venv_dir}/passwords.py":
            content => template("buildmaster/passwords.py.erb"),
            mode => 600,
            owner => $user::builder::username,
            group => $user::builder::username;
        "/etc/nrpe.d/pulse_publisher.cfg":
            content => template("buildmaster/pulse_publisher.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
    }
    service {
        "command_runner":
            hasstatus => true,
            require => [
                File["/etc/init.d/command_runner"],
                File["${queue_venv_dir}/run_command_runner.sh"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
        "pulse_publisher":
            hasstatus => true,
            require => [
                File["/etc/init.d/pulse_publisher"],
                File["${queue_venv_dir}/run_pulse_publisher.sh"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
    }
}
