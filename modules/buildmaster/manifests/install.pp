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
    include packages::gcc
    include packages::make
    include packages::mercurial
    include packages::mysql-devel
    include packages::mozilla::git
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include buildmaster::settings
    include buildmaster::virtualenv
    include buildmaster::repos
    include buildmaster::queue


    if $num_masters == '' {
        fail("you must set num_masters")
    }

    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }

    $test_ven="VIRTUALENV=${buildmaster::settings::virtualenv_dir}"
    $test_py="PTYHON=${buildmaster::settings::virtualenv_dir}/bin/python"
    $test_cwd="CWD=>$buildmaster::settings::buildbot_configs_dir"
    exec {
        "make-buildbot":
            command => "echo '$test_ven $test_py $test_cwd';/usr/bin/make -f Makefile.setup all BASEDIR=${buildmaster::settings::master_dir} MASTER_NAME=${buildmaster::settings::master_name}",
            user => $users::buildmaster::username,
            cwd => $buildmaster::settings::buildbot_configs_dir,
            environment => [
             "VIRTUALENV=${buildmaster::settings::virutalenv_dir}",
             "PTYHON=${buildmaster::settings::virtualenv_dir}/bin/python"
            ],
    }
}
