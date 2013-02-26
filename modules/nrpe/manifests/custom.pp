# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::custom($content) {
    include nrpe::setting
    $name=$title
    file {
        "${nrpe::settings::plugins_dir}/${name}":
            content => $content,
            require => Package["nrpe"],
            notify => Class['nrpe::service'];
    }
}
