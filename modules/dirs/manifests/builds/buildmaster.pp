class dirs::builds::buildmaster {
    include dirs::builds
    include dirs::tools
    include users::builder
    include config
    include buildmaster::settings

    file {
        "/etc/default/buildbot.d/":
            owner => "root",
            group => "root",
            mode => 755,
            ensure => directory;
        "/etc/init.d/buildbot":
            source => "puppet:///modules/buildmaster/buildbot.initd",
            mode => 755,
            owner => "root",
            group => "root";
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600,
            owner => "root",
            group => "root";
        "/etc/nagios/nrpe.d/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
            owner => "root",
            group => "root";
    }
}


