# buildmaster::queue class
# sets up queue processors for pulse, commands, etc.

class buildmaster::queue {
    include config
    include users::builder
    include buildmaster::settings
    include buildmaster::virtualenv

    $queue_venv_dir = "$users::builder::home/queue"

    exec {
        # Clone/install tools
        "clone-tools":
            require => [
                        Package["mercurial"],
                        Python::Virtualenv[$queue_venv_dir],
                       ],
            creates => "$queue_venv_dir/tools",
            command => "/usr/bin/hg clone http://hg.mozilla.org/build/tools $queue_venv_dir/tools",
            user => $users::builder::username;
        "install-tools":
            require => Exec["clone-tools"],
            creates => "$queue_venv_dir/lib/python2.7/site-packages/buildtools.egg-link",
            command => "$queue_venv_dir/bin/python setup.py develop",
            cwd => "$queue_venv_dir/tools",
            user => $users::builder::username;
    }

    file {
        "/etc/init.d/command_runner":
            content => template("buildmaster/command_runner.initd.erb"),
            notify => Service["command_runner"],
            mode => 755,
            owner => "root",
            group => "root";
        "$queue_venv_dir/run_command_runner.sh":
            require => Python::Virtualenv["$queue_venv_dir"],
            content => template("buildmaster/run_command_runner.sh.erb"),
            notify => Service["command_runner"],
            mode => 755,
            owner => "root",
            group => "root";
        "/etc/nagios/nrpe.d/command_runner.cfg":
            content => template("buildmaster/command_runner.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
            owner => "root",
            group => "root";
        "/etc/init.d/pulse_publisher":
            content => template("buildmaster/pulse_publisher.initd.erb"),
            notify => Service["pulse_publisher"],
            mode => 755,
            owner => "root",
            group => "root";
        "$queue_venv_dir/run_pulse_publisher.sh":
            require => Python::Virtualenv["$queue_venv_dir"],
            content => template("buildmaster/run_pulse_publisher.sh.erb"),
            notify => Service["pulse_publisher"],
            mode => 755,
            owner => "root",
            group => "root";
        "$queue_venv_dir/passwords.py":
            require => Python::Virtualenv["$queue_venv_dir"],
            content => template("buildmaster/passwords.py.erb"),
            mode => 600,
            owner => $users::builder::username,
            group => $users::builder::group;
        "/etc/init.d/nrpe.d/pulse_publisher.cfg":
            content => template("buildmaster/pulse_publisher.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
            owner => "root",
            group => "root";
    }
    service {
        "command_runner":
            hasstatus => true,
            require => [
                Python::Virtualenv["$queue_venv_dir"],
                File["/etc/init.d/command_runner"],
                File["$queue_venv_dir/run_command_runner.sh"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
        "pulse_publisher":
            hasstatus => true,
            require => [
                Python::Virtualenv["$queue_venv_dir"],
                File["/etc/init.d/pulse_publisher"],
                File["$queue_venv_dir/run_pulse_publisher.sh"],
                Exec["install-tools"],
                ],
            enable => true,
            ensure => running;
    }
}
