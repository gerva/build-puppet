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
    include packages::mozilla::py27_virtualenv
    include nrpe::settings
    include nrpe::service
    include users::builder
    include buildmaster::settings
    $master_group = $users::builder::group
    $master_user = $users::builder::username
    $master_basedir = $buildmaster::settings::master_root

    $master_name = $name
    $full_master_dir = "$master_basedir/$basedir"
    $buildbot_configs_dir ="${full_master_dir}/buildbot-configs"

    if $num_masters == '' {
        fail("you must set num_masters")
    }

    # Different types of masters require different BuildSlaves.py files
    $buildslaves_template = "BuildSlaves-${master_type}.py.erb"

    if ($buildslaves_template) {
        file {
            "${full_master_dir}/master/BuildSlaves.py":
                require => Exec["setup-$basedir"],
                owner => $master_user,
                group => $master_group,
                mode => 600,
                content => template("buildmaster/${buildslaves_template}");
        }
    }

    file {["${full_master_dir}",
        "${buildbot_configs_dir}",
        "${full_master_dir}/master"
        ]:
            owner => $master_user,
            group => $master_group,
            ensure => "directory";
    }

    file {
        "${full_master_dir}/master/passwords.py":
            require => Exec["setup-$basedir"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/passwords.py.erb");

        "${full_master_dir}/master/postrun.cfg":
            require => Exec["setup-$basedir"],
            owner => $master_user,
            group => $master_group,
            mode => 600,
            content => template("buildmaster/postrun.cfg.erb");

        "/etc/default/buildbot.d/${master_name}":
            content => $full_master_dir,
            require => Exec["setup-${basedir}"],

        "/etc/cron.d/${master_name}":
            require => Exec["setup-${basedir}"],
            mode => 600,
            content => template("buildmaster/buildmaster-cron.erb");
    }

    buildmaster::repos {
        "clone-buildbot-${master_name}":
            repo_name => 'buildbot-configs',
            dst_dir => $buildbot_configs_dir;
    }

    exec {
        "setup-${basedir}":
            require => Buildmaster::Repos["clone-buildbot-${master_name}"],
            command => "/usr/bin/make -f Makefile.setup all BASEDIR=$full_master_dir MASTER_NAME=$master_name",
            creates => "${full_master_dir}/master",
            user => $master_user,
            group => $master_group,
            logoutput => on_failure,
            environment => [
                "VIRTUALENV=/tools/python27-virtualenv/bin/virtualenv",
                "PYTHON=/tools/python27/bin/python2.7",
                "HG=/tools/python27-mercurial/bin/hg",
                "MASTERS_JSON=https://raw.github.com/gerva/build-tools/803823/buildfarm/maintenance/production-masters.json",
            ],
            cwd => "${buildbot_configs_dir}";
    }
}
