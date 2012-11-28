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
            creates => "${buildmaster::settings::master_basedir}/buildbot",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/buildbot ${buildmaster::settings::master_basedir}/buildbot",
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

    $master_name='build1'
    $full_master_dir="${buildmaster::settings::master_basedir}/$master_name"
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
        "setup-buildbot":
            require => [
                Exec["clone-buildbot"],
        ],
            command => "make -f Makefile.setup all BASEDIR=${buildmaster::settings::master_basedir} MASTER_NAME=build'",
            creates => "$full_master_dir/master",
            user => $users::buildmaster::username,
            environment => [
                "HG=/tools/python27-mercurial/bin/hg",
                "VIRTUALENV=/usr/bin/virtualenv-2.7",
                "PYTHON=/usr/local/bin/virtualenv",
                "PIP_DOWNLOAD_CACHE=${buildmaster::settings::master_basedir}/pip_cache",
                "PIP_FLAGS=--no-deps --no-index #--find-links=$python_package_dir",
                "MASTERS_JSON=http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json-wrongonpurpose",
            ],
            # --find_links is disabled for now
            cwd => "$master_basedir/buildbot-configs";
    }
}
