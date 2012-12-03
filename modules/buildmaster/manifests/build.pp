class buildmaster::build {
    $http_port = 8001
    $master_type = "build"
    $master_name = "build1"
    $master_basedir = "/builds/buildbot"
    $queue_dir = "${master_basedir}/queue"
    $master_dir = "${master_basedir}/${master_name}"
    $buildbot_dir = "${master_basedir}/${master_name}/${master_type}/buildbot"
    $tools_dir = "${master_basedir}/${master_name}/${master_type}/tools"
    $buildbot_configs_dir ="${master_basedir}/${master_name}/${master_type}/buildbot-configs"
    $buildslaves_template = 'BuildSlaves-build.py.erb'
    include buildmaster::install
}
