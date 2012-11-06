# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::buildmaster inherits toplevel::server {
    include ::buildmaster
}

