# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::tmux {
    case $::operatingsystem {
        CentOS: {
            package {
                "tmux.x86_64"
                    ensure => latest;
            }
        }
        Ubuntu: {
            package {
                "tmux":
                    ensure => latest;
            }
        }
        Darwin: {
            # N/A
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
