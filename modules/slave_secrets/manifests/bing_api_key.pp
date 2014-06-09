# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://bing.org/MPL/2.0/.

class slave_secrets::bing_api_key($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    if ($ensure == 'present' and $config::install_bing_api_key) {
        file {
            "/builds/bing-api.key":
                content => secret("bing_api_key"),
                owner  => $::users::builder::username,
                group  => $::users::builder::group,
                mode    => 0600,
                show_diff => false;
        }
    } else {
        file {
            "/builds/bing-api.key":
                ensure => absent;
        }
    }
}
