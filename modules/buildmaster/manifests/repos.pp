# buildmaster repo class
# creates the souce code repoitories
class buildmaster::repos {

    $hg_repo = "http://hg.mozilla.org/build/"
    exec {
        # Clone buildbot
        "clone-buildbot":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            creates => "${buildmaster::settings::buildbot_dir}",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/buildbot ${buildbot_dir}",
            user => "$users::builder::username";
        # Clone/install tools and buildbot-configs
        "clone-tools":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            creates => "${buildmaster::settings::tools_dir}",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/tools ${tools_dir}",
            user => "$users::builder::username";
        "clone-configs":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            creates => "${buildmaster::settings::buildbot_configs_dir}",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/buildbot-configs ${buildbot_configs_dir}",
            user => "$users::builder::username";
    }

    #exec {
    #    # install tools
    #    "install-tools":
    #        require => Exec["clone-tools"],
    #        creates => "${buildmaster::settings::queue_venv_dir}/lib/python2.7/site-packages/buildtools.egg-link",
    #        command => "/tools/python27/bin/python2.7 setup.py develop",
    #        cwd => "${buildmaster::settings::queue_venv_dir}/tools",
    #        user => $users::buildmaster::username;
    #}
}
