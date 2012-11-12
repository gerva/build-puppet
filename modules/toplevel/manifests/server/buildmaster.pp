# buildbot master

class toplevel::server::buildmaster inherits toplevel::server {

    include packages::mercurial
    include buildmaster
}

