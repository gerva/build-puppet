define buildmaster::virtualenv($virtualenv_dir, $user, $group) {
    include packages::mozilla::python27

    python::virtualenv {
        "${virtualenv_dir}":
            python => "/tools/python27/bin/python2.7",
            user => $user,
            group => $group,
        # packages downloaded by make
    }
}
