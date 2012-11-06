class ganglia::config-moco {
    include users::root
    
    $mode = "mcast"
    # Mozilla configuration
    case $fqdn {
        /^.*\.srv\.releng\.scl3\.mozilla\.com$/: {
            $cluster = "RelEngSCL3Srv"
            $addr = "239.2.11.204"
        }
        /^.*\.build\.scl1\.mozilla\.com$/: {
            $cluster = "RelEngSCL1"
            $addr = "239.2.11.201"
        }
        /^.*\.releng\.scl1\.mozilla\.com$/: {
            # note that there's no ganglia server in these VLANs, so this doesn't
            # actually work, but it at least gets the hosts configured
            $cluster = "RelEngSCL1"
            $addr = "239.2.11.201"
        }
        /^.*\.build\.mtv1\.mozilla\.com$/: {
            $cluster = "RelEngMTV1"
            $addr = "239.2.11.203"
        }
        default: {
            fail("Unsupported fqdn")
        }
    }
    
    file {
        "/etc/ganglia/gmond.conf":
            notify => Service['gmond'],
            require => Class['packages::ganglia'],
            content => template("ganglia/moco-gmond.conf.erb"),
            owner => "root",
            group => "$::users::root::group",
            mode => 644;
    }
}
