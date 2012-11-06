# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::server::buildmaster inherits toplevel::server {
    include ::buildmaster
}

