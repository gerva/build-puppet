# Set up a particular buildbot master instance
# The master information must already be in production-masters.json and setup-masters.py
#
# $basedir refers to the name of the directory under $master_basedir
# (/builds/buildbot) where the master's files will live. It corresponds to the
# 'basedir' key in the masters json.
#
# The master's name must reference one of the masters supported by setup-masters.py
#
# $master_type must be one of 'build', 'try', 'tests', or 'scheduler'
#
# TODO: Discover http_port from json?
# TODO: determine master_type from json?
define buildmaster::buildbot_master($basedir, $master_type, $http_port) {
    include buildmaster
    $master_group = $users::builder::group
    $master_user = $users::builder::username
    $master_basedir = $buildmaster::settings::master_root

    anchor {
        'buildmaster::buildbot_master::$basedir::$master_type::$http_port::begin': ;
        'buildmaster::buildbot_master::$basedir::$master_type::$http_port::end': ;
    }

    $master_name = $name
    $full_master_dir = "$master_basedir/$basedir"

    $virtualenv_dir = "${full_master_dir}/venv"
    $python_executalbe = "${full_master_dir}/venv/bin/python"
    $buildbot_configs_dir ="${full_master_dir}/buildbot-configs"

    if $num_masters == '' {
        fail("you must set num_masters")
    }

    # Different types of masters require different BuildSlaves.py files
    $buildslaves_template = "BuildSlaves-$master_type.py.erb"

    if ($buildslaves_template) {
        file {
            "$full_master_dir/master/BuildSlaves.py":
                require => Exec["setup-$basedir"],
                owner => $master_user,
                group => $master_group,
                mode => 600,
                content => template("buildmaster/$buildslaves_template");
        }
    }

    file {["$master_basedir",
        "$virtualenv_dir",
        "$full_master_dir",
        "$buildbot_configs_dir",
        "$full_master_dir/master"
        ]:
            owner => $master_user,
            group => $master_group,
            ensure => "directory";
    } -> Anchor['buildmaster::buildbot_master::$basedir::$master_type::$http_port::begin']

    file {
        "$full_master_dir/master/passwords.py":
            require => Exec["setup-$basedir"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/passwords.py.erb");

        "$full_master_dir/master/postrun.cfg":
            require => Exec["setup-$basedir"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/postrun.cfg.erb");

        "/etc/default/buildbot.d/$basedir":
            content => $full_master_dir,
            require => [
                File["/etc/default/buildbot.d"],
                Exec["setup-$basedir"],
                ];

        "/etc/cron.d/$master_name":
            require => Exec["setup-$basedir"],
            owner => "root",
            group => "root",
            mode => 600,
            content => template("buildmaster/buildmaster-cron.erb");
    }

    buildmaster::virtualenv {
        "creating-virtulenv":
            virtualenv_dir => $virtualenv_dir
    } -> Anchor['buildmaster::buildbot_master::$basedir::$master_type::$http_port::end']

    buildmaster::repos {
        "clone-buildbot-$master_type":
            repo_name => 'buildbot-configs',
            dst_dir => $buildbot_configs_dir;
    } -> Anchor['buildmaster::buildbot_master::$basedir::$master_type::$http_port::end']

    exec {
        "setup-$basedir":
            command => "/bin/bash -c && make -f Makefile.setup all BASEDIR=$full_master_dir MASTER_NAME=$master_name'",
            creates => "$full_master_dir/master",
            user => $master_user,
            logoutput => on_failure,
            environment => [
                "HG=/usr/bin/hg",
                "VIRTUALENV=/usr/bin/virtualenv-2.6",
                "PYTHON=${python_executalbe}",
                #"MASTERS_JSON=http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json",
            ],
            cwd => "$master_basedir/buildbot-configs";
    } -> Anchor['buildmaster::buildbot_master::$basedir::$master_type::$http_port::end']
}
