# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include dirs::builds::buildmaster
}

