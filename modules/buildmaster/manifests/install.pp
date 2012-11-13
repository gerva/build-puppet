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
    include dirs::buildmaster
    include packages::mercurial
    include buildmaster::queue
    include buildmaster::settings
    $master_user = $buildmaster::settings::master_user
    $master_group = $buildmaster::settings::master_group
    $master_user_uid = $buildmaster::settings::master_user_uid
    $master_group_gid = $buildmaster::settings::master_group_gid
    $master_basedir = $buildmaster::settings::master_basedir
    $plugins_dir = $buildmaster::settings::plugins_dir

   if $num_masters == '' {
        fail("you must set num_masters")
    }
    package {
        "python26":
            ensure => latest;
        "python26-virtualenv":
            ensure => latest;
        "mysql-devel":
            ensure => latest;
        "git":
            ensure => latest;
        "gcc":
            ensure => latest;
    }
    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }

    exec {
        "clone-configs":
            creates => "$master_basedir/buildbot-configs",
            command => "/usr/bin/hg clone -r production http://hg.mozilla.org/build/buildbot-configs",
            user => $master_user,
            cwd => $master_basedir;
    }
}
