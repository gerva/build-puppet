# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define python::user_pip_conf($homedir='', $group='') {
    include config

    $user = $title
    if ($homedir != '') {
        $homedir_ = $homedir
    } else {
        $homedir_ = $::operatingsystem ? {
            Darwin => "/Users/$user",
            default => "/home/$user"
        }
    }

    if ($group != '') {
        $group_ = $group
    } else {
        $group_ = $user
    }

    # for the template
    $data_servers = $config::data_servers
    $data_server = $config::data_server

    file {
        "$homedir_/.pip":
            ensure => directory,
            owner => $user,
            group => $group_,
            mode => 0755;
        "$homedir_/.pip/pip.conf":
            content => template("python/user-pip-conf.erb"),
            owner => $user,
            group => $group_,
            mode => 0644;
    }
}
