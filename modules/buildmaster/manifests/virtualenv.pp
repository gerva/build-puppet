class buildmaster::virtualenv {
    include buildmaster::settings
    include packages::mozilla

    python::virtualenv {
        "$buildmaster::settings::master_queue_venv"
            python => "/usr/bin/python2.6",
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
