class buildmaster::try {
    http_port => 8101,
    master_type => "try",
    basedir => "try1",
    $buildslaves_template = 'BuildSlaves-try.py.erb',
}
