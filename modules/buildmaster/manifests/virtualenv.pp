class buildmaster::virtualenv {
    include packages::mozilla::python27

    python::virtualenv {
        "$buildmaster::queue::queue_venv_dir":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
                "simplejson",
                "buildbot==0.8.4-pre-moz1",
                "Twisted==10.1.0",
                "zope.interface==3.6.1",
                "mozillapulse==.4",
                "carrot==0.10.7",
                "amqplib==0.6.1",
                "anyjson==0.3",
                "pytz==2011d",
            ],
    }
}
