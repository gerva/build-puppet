# buildmaster repo class
# creates the souce code repoitories
class buildmaster::repos {

    $hg_repo = "http://hg.mozilla.org/build/"
    exec {
        # make will take care of checking out
        # buildbotcustom and tools
        "clone-configs":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            creates => "${buildmaster::settings::buildbot_configs_dir}",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/buildbot-configs ${buildmaster::settings::buildbot_configs_dir}",
            user => "$users::builder::username";
    }
}
