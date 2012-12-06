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
    include secrets
    include buildmaster::queue
    include buildmaster::settings
    include sysctl
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
    $plugins_dir = $nagios::service::plugins_dir
    $nagios_etcdir = $nagios::service::etcdir
    file {
        $master_basedir:
            ensure => directory,
            owner => $users::builder::username,
            group => $users::builder::group;
        "/etc/default/buildbot.d/":
            ensure => directory,
            mode => 755;
        "/etc/init.d/buildbot":
            source => "puppet:///modules/buildmaster/buildbot.initd",
            mode => 755;
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600;
        # this has to be fixed
        "${nagios_etcdir}/nrpe.d/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            notify => Service["nrpe"],
            require => Class["nagios"],
            mode => 644;
        "/tools":
            ensure => "directory";
    }
    sysctl::value {
         "net.ipv4.tcp_keepalive_time":
            value => "240"
    }

    #todo fix it:
    buildmaster::repo {
        "clone-buildbot":
        repo_name => 'buildbot-configs',
        dst_name => '/tmp'
    }
    #exec {
    #    "clone-configs":
    #        creates => "$master_basedir/buildbot-configs",
    #        command => "/usr/bin/hg clone -r production http://hg.mozilla.org/build/buildbot-configs",
    #        user => $users::builder::username,
    #        cwd => $master_basedir;
    #}
}
