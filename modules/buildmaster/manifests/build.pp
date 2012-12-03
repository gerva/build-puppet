class buildmaster::build {
    include buildmaster::settings
    $http_port = 8001
    $master_type = "build"
    $basedir = "build1"
    $buildslaves_template = 'BuildSlaves-build.py.erb'
    $full_master_dir="${buildmaster::settings::master_basedir}/$basedir"
    include buildmaster::install
}
