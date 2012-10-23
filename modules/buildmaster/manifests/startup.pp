# Ensure that a buildslave starts up on this machine

class buildslave::startup {
    anchor {
        'buildslave::startup::begin': ;
        'buildslave::startup::end': ;
    }

    include ::shared
    include buildslave::install
    include dirs::usr::local::bin
    include users::root

    # everyone uses runslave.py in the same place
    file {
        "/usr/local/bin/runslave.py":
            source => "puppet:///modules/buildslave/runslave.py",
            owner  => "root",
            group => $users::root::group,
            mode => 755;
    }

    # select an implementation class based on operating system
    $startuptype = $operatingsystem ? {
        CentOS      => "initd",
        Darwin      => "launchd"
        # not done in PuppetAgain yet:
        #Fedora      => "desktop",
    }
    Anchor['buildslave::startup::begin'] ->
    class {
        "buildslave::startup::$startuptype":
    } -> Anchor['buildslave::startup::end']
}
