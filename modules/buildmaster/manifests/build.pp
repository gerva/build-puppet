class buildmaster::build {
    $http_port = 8001
    $master_type = "build"
    $basedir = "build1"
    $buildslaves_template = 'BuildSlaves-build.py.erb',
    include buildmaster::install
}
