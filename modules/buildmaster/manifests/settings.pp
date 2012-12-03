class buildmaster::settings {
    include users::builder

    $master_basedir = "/builds/buildbot"
    $queue_dir = "${master_basedir}/queue"
    $buildbot_dir = "${master_basedir}/${master_name}/${master_type}/buildbot"
    $tools_dir = "${master_basedir}/${master_name}/${master_type}/tools"
    $buildbot_configs_dir ="${master_basedir}/${master_name}/${master_type}/buildbot-configs"
}
