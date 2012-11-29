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
    include buildmaster::repos
    include buildmaster::queue

    anchor {
        'buildmaster::install::begin': ;
        'buildmaster::install::end': ;
    }


    if $num_masters == '' {
        fail("you must set num_masters")
    }

    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }

    file {
        "$buildmaster::settings::master_basedir":
            owner => "$users::builder::username",
            group => "$users::builder::username",
            ensure => directory;
    }
}
