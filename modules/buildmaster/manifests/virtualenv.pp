class buildmaster::virtualenv {
    include buildmaster::settings
    include packages::mozilla::python27

    python::virtualenv {
        "${buildmaster::settings::queue_venv_dir}/build":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
            "Jinja2==2.5.5",
            "MySQL-python==1.2.3",
            "SQLAlchemy==0.6.4",
            "Twisted==10.1.0",
            "amqplib==0.6.1",
            "anyjson==0.3",
            "argparse==1.1",
            "carrot==0.10.7",
            "distibute==0.6.14",
            "pyOpenSSl==0.10",
            "pyasn1==0.0.11a",
            "pycrypto==2.3",
            "buildbot-slave==0.8.4-pre-moz2"
            "pytz==pytz-2011d",
            "zope.interface==3.6.1",
            "mozillapulse==ad95569a089e",
            "wsgiref==0.1.2",
            ],
    }
}
