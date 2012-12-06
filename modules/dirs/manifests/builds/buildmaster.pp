class dirs::builds::buildmaster {
    include dirs::builds
    include dirs::tools
    include users::builder
    include config

    file {
        "/etc/default/buildbot.d/":
            ensure => directory,
            mode => 755;
        "/etc/init.d/buildbot":
            source => "puppet:///modules/buildmaster/buildbot.initd",
            mode => 755;
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600;
        "/etc/nagios/nrpe.d/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644;
    }
}


