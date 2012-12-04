class buildmaster::settings {
    include users::builder

    $master_root = "/builds/buildbot"
    $queue_dir = "${master_root}/queue"
    $master_basedir = "${master_root}/${master_name}"
    $master_dir = "${master_basedir}/${master_type}"
    $tools_dir = "${master_dir}/tools"
    $buildbot_dir = "${master_dir}/buildbot"
    $virtualenv_dir = "${master_dir}/venv"
    $buildbot_configs_dir ="${master_dir}/buildbot-configs"
}
