class buildmaster::virtualenv {
    include buildmaster::settings
    include packages::mozilla::python27

    python::virtualenv {
        "$buildmaster::settings::queue_venv_dir":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
            #    "simplejson==http://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.5.5.tar.gz#md5=83b20c1eeb31f49d8e6392efae91b7d5",
            #    "MySQL-python==http://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.3.tar.gz#md5=215eddb6d853f6f4be5b4afc4154292f",
            #    "SQLAlchemy==http://pypi.python.org/packages/source/S/SQLAlchemy/SQLAlchemy-0.6.4.tar.gz#md5=f1e553e73ca989c162ea039b55bd93f5",
            #    "buildbot==http://puppetagain.pub.build.mozilla.org/data/python/packages/buildbot-slave-0.8.4-pre-moz2.tar.gz"
            #    "Twisted==http://pypi.python.org/packages/source/T/Twisted/Twisted-10.1.0.tar.bz2#md5=04cca97506e830074cffc1965297da3f",
            #    "zope.interface==http://pypi.python.org/packages/source/z/zope.interface/zope.interface-3.6.1.tar.gz#md5=7a895181b8d10be4a7e9a3afa13cd3be",
            #    "mozillapulse==http://hg.mozilla.org/users/clegnitto_mozilla.com/mozillapulse/archive/ad95569a089e.tar.bz2",
            #    "carrot==http://pypi.python.org/packages/source/c/carrot/carrot-0.10.7.tar.gz#md5=530a0614de3a669314c3acd4995c54d5",
            #    "amqplib==http://pypi.python.org/packages/source/a/amqplib/amqplib-0.6.1.tgz#md5=b2f6679b27eaae97c50a9c3504154fae",
            #    "anyjson==http://pypi.python.org/packages/source/a/anyjson/anyjson-0.3.tar.gz#md5=28124eeb1a96e6631ae67bcb7a30ef48",
            #    "argparse==http://pypi.python.org/packages/source/a/argparse/argparse-1.1.zip#md5=087399b73047fa5a6482037411ddc968",
            #    "distibute==http://pypi.python.org/packages/source/d/distribute/distribute-0.6.14.tar.gz#md5=83ada58a83d99b28c806703597323b80",
            #    "puOpenSSl==http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.10.tar.gz#md5=34db8056ec53ce80c7f5fc58bee9f093",
            #    "pysan==http://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.0.11a.tar.gz#md5=a99ff02b24a98614f34ba196208d9cac",
            #    "pycrpto==http://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.3.tar.gz#md5=2b811cfbfc342d83ee614097effb8101",
            #    "pytz==http://pypi.python.org/packages/source/p/pytz/pytz-2012h.tar.gz#md5=d4cce6b41401d561b62107eeedd4a936",
            #    "wsgiref==http://pypi.python.org/packages/source/w/wsgiref/wsgiref-0.1.2.zip#md5=29b146e6ebd0f9fb119fe321f7bcf6cb",
                "http://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.5.5.tar.gz#md5=83b20c1eeb31f49d8e6392efae91b7d5",
                "http://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.3.tar.gz#md5=215eddb6d853f6f4be5b4afc4154292f",
                "http://pypi.python.org/packages/source/S/SQLAlchemy/SQLAlchemy-0.6.4.tar.gz#md5=f1e553e73ca989c162ea039b55bd93f5",
                "http://puppetagain.pub.build.mozilla.org/data/python/packages/buildbot-slave-0.8.4-pre-moz2.tar.gz",
                "http://pypi.python.org/packages/source/T/Twisted/Twisted-10.1.0.tar.bz2#md5=04cca97506e830074cffc1965297da3f",
                "http://pypi.python.org/packages/source/z/zope.interface/zope.interface-3.6.1.tar.gz#md5=7a895181b8d10be4a7e9a3afa13cd3be",
                "http://hg.mozilla.org/users/clegnitto_mozilla.com/mozillapulse/archive/ad95569a089e.tar.bz2",
                "http://pypi.python.org/packages/source/c/carrot/carrot-0.10.7.tar.gz#md5=530a0614de3a669314c3acd4995c54d5",
                "http://pypi.python.org/packages/source/a/amqplib/amqplib-0.6.1.tgz#md5=b2f6679b27eaae97c50a9c3504154fae",
                "http://pypi.python.org/packages/source/a/anyjson/anyjson-0.3.tar.gz#md5=28124eeb1a96e6631ae67bcb7a30ef48",
                "http://pypi.python.org/packages/source/a/argparse/argparse-1.1.zip#md5=087399b73047fa5a6482037411ddc968",
                "http://pypi.python.org/packages/source/d/distribute/distribute-0.6.14.tar.gz#md5=83ada58a83d99b28c806703597323b80",
                "http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.10.tar.gz#md5=34db8056ec53ce80c7f5fc58bee9f093",
                "http://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.0.11a.tar.gz#md5=a99ff02b24a98614f34ba196208d9cac",
                "http://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.3.tar.gz#md5=2b811cfbfc342d83ee614097effb8101",
                "http://pypi.python.org/packages/source/p/pytz/pytz-2012h.tar.gz#md5=d4cce6b41401d561b62107eeedd4a936",
                "http://pypi.python.org/packages/source/w/wsgiref/wsgiref-0.1.2.zip#md5=29b146e6ebd0f9fb119fe321f7bcf6cb",
            ],
    }
}
