# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::virtualenv {
    include packages::mozilla::python27
    include mozpool::settings
    include config::secrets

    python::virtualenv {
        "$mozpool::settings::root/frontend":
            python => $::packages::mozilla::python27::python,
            require => Class['packages::mozilla::python27'],
            packages => [
                "argparse==1.1",
                "SQLAlchemy==0.7.9",
                "web.py==0.37",
                "requests==1.0.4",
                "lockfile==0.9.1",
                "python-daemon==1.5.5",
                "which==1.1.0",
                "Tempita==0.5.1",
                'templeton==0.6.2',
                "flup==1.0.3.dev-20110405",
                "pymysql==0.5",
                "mozdevice==0.18",
                "mozprocess==0.8",
                "mozinfo==0.4",
                "mozpool==${mozpool::settings::mozpool_version}",
            ],
            notify => Service['supervisord'];
    }

    # add the virtualenv's bin/ to the global PATH
    shellprofile::file {
        "mozpool_path":
            content => "export PATH=\$PATH:${mozpool::settings::root}/frontend/bin";
    }
}
