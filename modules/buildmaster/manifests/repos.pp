# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster repo class
# creates the souce code repoitories
define buildmaster::repos($hg_repo, $dst_dir) {

    exec {
        # make will take care of checking out
        # buildbotcustom and tools
        "clone-${dst_dir}":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            command => "/tools/python27-mercurial/bin/hg clone $hg_repo $dst_dir",
            user => "$users::builder::username";
    }
}
