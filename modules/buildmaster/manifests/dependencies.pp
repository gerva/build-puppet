class buildmaster::dependencies {
    case $::operatingsystem {
        CentOS: {
            package {
                "git":
                    ensure => latest;
                "mysql-devel":
                    ensure => latest;
                "gcc":
                    ensure => latest;
                "make":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
