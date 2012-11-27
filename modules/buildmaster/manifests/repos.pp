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
                user => "$users::builder::username";
            ],
            creates => "${buildmaster::settings::queue_venv_dir}/buildbot",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/build ${buildmaster::settings::queue_venv_dir}/buildbot",
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
}
