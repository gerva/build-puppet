# buildbot master

class toplevel::buildmaster inherits toplevel::base {
    include package::mercurial
    include buildmaster
}

