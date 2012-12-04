class buildmaster::build {
    $http_port = 8001
    $master_type = "build"
    $master_name = "build1"
    $buildslaves_template = 'BuildSlaves-build.py.erb'
    include buildmaster::dirs
    include buildmaster::install
}
