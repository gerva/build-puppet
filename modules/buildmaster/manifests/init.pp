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
class buildmaster {
    # TODO: port releng module
    #include releng::master
    #include secrets
    include buildmaster::queue
    include buildmaster::settings
    include buildmaster::tools
    $master_basedir = $buildmaster::settings::master_basedir
    $clone_config_dir = $buildmaster::settings::master_basedir
    if $num_masters == '' {
        fail("you must set num_masters")
    }
    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }
    sysctl::value {
        "net.ipv4.tcp_keepalive_time":
            value => "240"
    }
    file {
        "/builds/buildbot":
             ensure => directory,
             owner => $users::builder::group,
             group => $users::builder::username,
    }


    #todo fix it:
    #exec {
    #    "clone-configs":
    #        creates => "$master_basedir/buildbot-configs",
    #        command => "/usr/bin/hg clone -r production http://hg.mozilla.org/build/buildbot-configs",
    #        user => $users::builder::username,
    #        cwd => $master_basedir;
    #}
}
