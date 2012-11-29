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


    case $::operatingsystem {
        CentOS: {
	    Anchor['buildmaster::install::begin'] ->
            package {
                "git":
                    ensure => latest;
                "mysql-devel":
                    ensure => latest;
                "gcc":
                    ensure => latest;
                "make":
                    ensure => latest;
            } -> Anchor['buildmaster::install::end']
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }

    $master_name='build'
    $full_master_dir="${buildmaster::settings::master_basedir}/$master_name"

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

    exec {
        "setup-buildbot":
            require => [
                Exec["clone-buildbot"],
        ],
            command => "make -f Makefile.setup all BASEDIR=${full_master_dir} MASTER_NAME=$master_name",
            creates => "${full_master_dir}/master",
            user => $users::buildmaster::username,
            environment => [
                "PYTHON=${buildmaster::s}/build/bin/virtualenv",
                #"MASTERS_JSON=http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json-wrongonpurpose",
            ],
            # --find_links is disabled for now
            cwd => "${buildmaster::settings::master_basedir}/buildbot-configs";
    }
}
