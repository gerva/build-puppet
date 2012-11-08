class buildmaster::scheduler {
    #TODO
    # http_port and basedir are just random...
    # find right values
    $http_port = 8301
    $master_type = "scheduler"
    $basedir = "scheduler1"
    $buildslaves_template = 'BuildSlaves-scheduler.py.erb'
    include buildmaster::install
}

