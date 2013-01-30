class buildmaster::tools {
    include packages::mozilla::python27
    include settings

    python::virtualenv {
        "$buildmaster::settings::queue_dir":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            user => $users::builder::username,
            group => $users::builder::group,
            packages => [
                "Jinja2==2.5.5",
                "MySQL-python==1.2.3",
                "SQLAlchemy==0.6.4",
                "Twisted==10.1.0",
                "amqplib==0.6.1",
                "anyjson==0.3",
                "argparse==1.1",
                "carrot==0.10.7",
                "distribute==0.6.14",
                "pyOpenSSL==0.10",
                "pyasn1==0.0.11a",
                "pycrypto==2.3",
                "pytz==2011d",
                "wsgiref==0.1.2",
                "zope.interface==3.6.1",
                "mozillapulse==ad95569a089e",
                "simplejson==2.1.6",
                "buildbot==0.8.4_pre_moz1",
            ];
    }
    exec {
        "clone-tools":
            require => [ File["${buildmaster::settings::queue_dir}"],
                         Python::Virtualenv["$buildmaster::settings::queue_dir"],
                         ],
            creates => "${buildmaster::settings::queue_dir}/tools",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/tools",
            user => $users::builder::username,
            group => $users::builder::group,
            cwd => "${buildmaster::settings::queue_dir}";
        "install-tools":
            require => Exec["clone-tools"],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop",
            cwd => "${buildmaster::settings::queue_dir}/tools",
            user => $users::builder::username,
            group => $users::builder::group;
    }
}
