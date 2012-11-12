# toplevel class for running a buildmaster type 'build'
class toplevel::buildmaster::server::build inherits toplevel::server::buildmaster {
    include ::buildmaster::build
}
