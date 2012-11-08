class buildmaster::tests {
    $http_port = 8201
    $master_type = "tests"
    $basedir = "tests1-macosx"
    $buildslaves_template = 'BuildSlaves-tests.py.erb'
    include buildmaster::install
}
