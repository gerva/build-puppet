# buildmaster class
# include this in your node to have all the base requirements for running a
# buildbot master installed
# To setup a particular instance of a buildbot master, see
# buildmaster::buildbot_master
#
# buildmaster requires that $num_masters be set on the node prior to including this class
#
# TODO: move $libdir stuff into template?
# TODO: you still have to set up ssh keys!
# TODO: determine num_masters from json (bug 647374)
class buildmaster::install {
    include nrpe::base
    include users::builder
    include dirs::builds::buildmaster
    include packages::mercurial
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include buildmaster::settings
    include buildmaster::virtualenv
    include buildmaster::queue

    if $num_masters == '' {
        fail("you must set num_masters")
    }
    case $::operatingsystem {
        CentOS: {
            package {
                "git":
                    ensure => latest;
                "mysql-devel":
                    ensure => latest;
                "gcc":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }

    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }

    exec {
        "clone-configs":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File['/builds/tools'],
            ],
            creates => "$buildmaster::settings::home/buildbot-configs",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/buildbot-configs .",
            cwd => "$buildmaster::settings::home/buildbot-configs",
            user => $users::builder::username;
    }
    file {
        #"/home/$master_user/.ssh":
        #   mode => 700,
        #   owner => $master_user,
        #   user => "$buildmaster::settings::username",
        #   group => "$buildmaster::settings::username",
        #   ensure => directory;
        "/builds":
            user => "$buildmaster::settings::username",
            group => "$buildmaster::settings::username",
            ensure => directory;
        "$buildmaster::settings::master_basedir":
            user => "$buildmaster::settings::username",
            group => "$buildmaster::settings::username",
            ensure => directory;
    }
}
