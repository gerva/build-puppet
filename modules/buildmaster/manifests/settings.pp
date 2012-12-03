class buildmaster::settings {
    include users::builder

    $master_basedir = "/builds/buildbot"
    $queue_dir = "${master_basedir}/queue"
}
