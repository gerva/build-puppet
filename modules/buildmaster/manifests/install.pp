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
    #user {
    #    $master_user:
    #        require => Group[$master_group],
    #        ensure => "present",
    #        name => $master_user,
    #        uid => $master_user_uid,
    #        gid => $master_group_gid,
    #        comment => "Client Builder",
    #        managehome => true,
    #        home => "/home/$master_user",
    #        shell => "/bin/bash",
    #        password => $secrets::cltbld_password;
    #}

    file {
        # already declared in ssh/manifest/userconfig.pp
        #"/home/$master_user/.ssh":
        #    mode => 700,
        #    owner => $master_user,
        #    group => $master_group,
        #    ensure => directory;
        "/builds":
            ensure => directory,
            owner => $master_user,
            group => $master_group;
        $master_basedir:
            ensure => directory,
            owner => $master_user,
            group => $master_group;
        "/etc/default/buildbot.d/":
            owner => "root",
            group => "root",
            mode => 755,
            ensure => directory;
        "/etc/init.d/buildbot":
            source => "puppet:///modules/buildmaster/buildbot.initd",
            mode => 755,
            owner => "root",
            group => "root";
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600,
            owner => "root",
            group => "root";
        "/etc/nagios/nrpe.d/buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
            notify => Class["nrpe::service"],
            require => Package["nrpe"],
            mode => 644,
            owner => "root",
            group => "root";
        "/tools":
            ensure => "directory";
    }
    exec {
        "clone-configs":
            creates => "$master_basedir/buildbot-configs",
            command => "/usr/bin/hg clone -r production http://hg.mozilla.org/build/buildbot-configs",
            user => $master_user,
            cwd => $master_basedir;
    }
}
