class buildmaster::settings {
    $master_basedir = "/builds/buildbot"
    $master_queue_venv = "${master_basedir}/queue"
    $plugins_dir = nrpe::base::plugins_dir
}
