# buildbot master

class toplevel::buildmaster inherits toplevel::base {
    include packages::mercurial
    include buildmaster
}

