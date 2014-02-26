# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::builds::buildbot {
    include users::builder
    include config
    include dirs::builds
    # bug 964880 Add swap to linux build machines with <12GB
    include tweaks::swap_on_instance_storage

    file {
        "/builds/buildbot" :
            ensure => directory,
            owner => "$users::builder::username",
            group => "$users::builder::group",
            mode => 0755;
    }
}
