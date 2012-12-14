class buildmaster::settings {

    $master_root = "/builds/buildbot"
    $queue_dir = "${master_root}/queue"
    $buildbot_statusdb_username = $::config::secrets::buildbot_statusdb_username
    $buildbot_statusdb_hostname = $::config::secrets::buildbot_statusdb_hostname
    $buildbot_statusdb_password = $::config::secrets::buildbot_statusdb_password
    $buildbot_statusdb_database = $::config::secrets::buildbot_statusdb_database
    $buildbot_schedulerdb_username = $::config::secrets::buildbot_schedulerdb_username
    $buildbot_schedulerdb_hostname = $::config::secrets::buildbot_schedulerdb_hostname
    $buildbot_schedulerdb_password = $::config::secrets::buildbot_schedulerdb_password
    $buildbot_schedulerdb_database = $::config::secrets::buildbot_schedulerdb_database
    $pulse_exchange = $::config::secrets::pulse_exchange_here
    $pulse_password = $::config::secrets::pulse_password_here
    $pulse_username = $::config::secrets::pulse_username_here
}
