# buildmaster repo class
# creates the souce code repoitories
class buildmaster::repos {
    include buildmaster::settings


    file {
        "${full_master_dir}":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => directory,
            mode => 0755;
    }

    $hg_repo = "http://hg.mozilla.org/build/"
    exec {
        # Clone buildbot
        "clone-buildbot":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${full_master_dir}"],
            ],
            creates => "${full_master_dir}/buildbot",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/buildbot ${full_master_dir}/buildbot",
            user => "$users::builder::username";
        # Clone/install tools and buildbot-configs
        "clone-tools":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${full_master_dir}"],
            ],
            creates => "${full_master_dir}/tools",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/tools ${full_master_dir}/tools",
            user => "$users::builder::username";
        "clone-configs":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File["${full_master_dir}"],
            ],
            creates => "${full_master_dir}/buildbot-configs",
            command => "/tools/python27-mercurial/bin/hg clone ${hg_repo}/buildbot-configs ${full_master_dir}/buildbot-configs",
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
