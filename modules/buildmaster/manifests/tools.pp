class buildmaster::tools {
    include packages::mozilla::python27
    include settings

    python::virtualenv {
        "$buildmaster::settings::queue_dir":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
                "distribute=0.6.26"
            ],
            notify => Service['supervisord'];
    }
    exec {
        "clone-tools":
            require => [ File["${buildmaster::settings::queue_dir}"], 
                         Python::Virtualenv["$buildmaster::settings::queue_dir"],
                         ],
            creates => "${buildmaster::settings::queue_dir}/tools",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/tools",
            user => $master_user,
            cwd => "${buildmaster::settings::queue_dir}";
        "install-tools":
            require => Exec["clone-tools"],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop",
            cwd => "${buildmaster::settings::queue_dir}/tools",
            user => $master_user;
}
