# buildbot master

class toplevel::buildmaster inherits toplevel::base {
    include nrpe
    #include nrpe::check::buildbot
    include packages::mercurial
    include buildmaster
}

