class buildmaster::settings {
    include users::builder

    $buildmaster_user = $users::builder::username
    $buildmaster_group = $users::builder::group
    $buildmaster_home = $users::builder::home
    $queue_venv_dir = "$build_home/queue"
    $master_basedir = "/builds/buildbot"
}
