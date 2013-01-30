# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Set up the root user (or equvalent, e.g., Administrator on windows)

class users::root {
    include ::config
    anchor {
        'users::root::begin': ;
        'users::root::end': ;
    }

    ##
    # public variables used by other modules
    $username = 'root' # here for symmetry; no need to use this everywhere

    $group = $::operatingsystem ? {
        Darwin => wheel,
        default => root
    }

    $home = $::operatingsystem ? {
        Darwin => '/var/root',
        default => '/root'
    }

    # account happens in the users stage, and is not included in the anchor
    class {
        'users::root::account':
            stage => users,
            username => $username,
            group => $group,
            home => $home;
    }

    Anchor['users::root::begin'] ->
    class {
        'users::root::setup':
            username => $username,
            group => $group,
            home => $home;
    } -> Anchor['users::root::end']
}
