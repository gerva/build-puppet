class buildmaster::settings {
    include users::builder

    $queue_venv_dir = "$users::builder::home/queue"
    $master_basedir = "/builds/buildbot"
}
