# buildbot master

class toplevel::buildmaster inherits toplevel::base {
    include packages::mercurial
    include nrpe
    include nrpe::check::buildbot
    include buildmaster
}

