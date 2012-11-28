# buildmaster repo class
# creates the souce code repoitories
class buildmaster::repos {
    include users::builder
    include dirs::tools
    include dirs::builds
    include dirs::builds::buildmaster
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include buildmaster::settings

    file {
        "${buildmaster::settings::queue_venv_dir}":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => directory,
            mode => 0755;
    }

    exec {
        # Clone buildbot
        "clone-buildbot":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${buildmaster::settings::queue_venv_dir}"],
            ],
            creates => "${buildmaster::settings::queue_venv_dir}/buildbot",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/buildbot ${buildmaster::settings::queue_venv_dir}/buildbot",
            user => "$users::builder::username";
        # Clone/install tools and buildbot-configs
        "clone-tools":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${buildmaster::settings::queue_venv_dir}"],
            ],
            creates => "${buildmaster::settings::queue_venv_dir}/tools",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/tools ${buildmaster::settings::queue_venv_dir}/tools",
            user => "$users::builder::username";
        "clone-configs":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${buildmaster::settings::queue_venv_dir}"],
            ],
            creates => "${buildmaster::settings::queue_venv_dir}/buildbot-configs",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/buildbot-configs ${buildmaster::settings::queue_venv_dir}/buildbot-configs",
            user => "$users::builder::username";
    }

    exec {
        # install tools
        "install-tools":
            require => Exec["clone-tools"],
            creates => "${buildmaster::settings::queue_venv_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "/tools/python27/bin/python2.7 setup.py develop",
            cwd => "${buildmaster::settings::queue_venv_dir}/tools",
            user => $users::buildmaster::username;
    }

    exec {
        "setup-$basedir":
            require => [
                Exec["clone-configs"],
        ],
            command => "/bin/bash -c '\$HG pull -u && make -f Makefile.setup all BASEDIR=$full_master_dir MASTER_NAME=$master_name'",
            creates => "$full_master_dir/master",
            user => $master_user,
            user => $users::buildmaster::username;
            environment => [
                "HG=/tools/python27-mercurial/bin/hg",
                "VIRTUALENV=/usr/bin/virtualenv-2.7",
                "PYTHON=/usr/local/bin/virtualenv",
                "PIP_DOWNLOAD_CACHE=$master_basedir/pip_cache",
                "PIP_FLAGS=--no-deps --no-index --find-links=$python_package_dir",
                "MASTERS_JSON=http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json",
            ],
            cwd => "$master_basedir/buildbot-configs";
    }
}
