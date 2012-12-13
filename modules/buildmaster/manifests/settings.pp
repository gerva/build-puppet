class buildmaster::settings {

    $master_root = "/builds/buildbot"
    $queue_dir = "${master_root}/queue"
    $buildbot_statusdb_user =  $::config::secrets::buildbot_statusdb_user
}
