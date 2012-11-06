class blackmobilemagic::config::frontend {
    include dirs::opt::bmm
    include packages::mozilla::python27
    include blackmobilemagic::settings
    include config::secrets

    python::virtualenv {
        "/opt/bmm/frontend":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
                "SQLAlchemy==0.7.9",
                "web.py==0.37",
                "requests==0.14.1",
                "lockfile==0.9.1",
                "python-daemon==1.5.5",
                "which==1.1.0",
                "Tempita==0.5.1",
                'templeton==0.6.1',
                "flup==1.0.3.dev-20110405",
                "pymysql==0.5",
                "blackmobilemagic==0.2.1",
            ],
            notify => Service['supervisord'];
    }

    file {
        $blackmobilemagic::settings::config_ini:
            content => template("blackmobilemagic/config.ini"),
            mode => 0755;
    }

    # only the admin node should do the inventory sync
    if ($is_bmm_admin_host) {
        notice("hi")
        file {
            "/etc/cron.d/bmm-inventorysync":
                content => "15,45 * * * * apache BMM_CONFIG=${::blackmobilemagic::settings::config_ini} /opt/bmm/frontend/bin/bmm-inventorysync\n";
        }
    } else {
        file {
            "/etc/cron.d/bmm-inventorysync":
                ensure => absent;
        }
    }

    # run the daemon on port 8010; Apache will proxy there
    supervisord::supervise {
      "bmm-server":
         command => "/opt/bmm/frontend/bin/bmm-server 8010",
         user => 'apache',
         environment => [ "BMM_CONFIG=${::blackmobilemagic::settings::config_ini}" ];
    }
}
