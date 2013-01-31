class buildmaster::tools {
    include packages::mozilla::python27
    include settings

    $python_packages_url = "http://puppetagain.pub.build.mozilla.org/data/python/packages/"
    python::virtualenv {
        "$buildmaster::settings::queue_dir":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            user => $users::builder::username,
            group => $users::builder::group,
            packages => [
                "${python_packages_url}/buildbot-0.8.4-pre-moz2.tar.gz",
                "${python_packages_url}/mozillapulse-ad95569a089e.tar.bz2",
                "${python_packages_url}/carrot-0.10.7.tar.gz",
            ];
    }
    exec {
        "clone-tools":
            require => [ File["${buildmaster::settings::queue_dir}"],
                         Python::Virtualenv["$buildmaster::settings::queue_dir"],
                         ],
            creates => "${buildmaster::settings::queue_dir}/tools",
            command => "/tools/python27-mercurial/bin/hg clone http://hg.mozilla.org/build/tools",
            user => $users::builder::username,
            group => $users::builder::group,
            cwd => "${buildmaster::settings::queue_dir}";
        "install-tools":
            require => Exec["clone-tools"],
            creates => "${buildmaster::settings::queue_dir}/lib/python2.7/site-packages/buildtools.egg-link",
            command => "${buildmaster::settings::queue_dir}/bin/python setup.py develop",
            cwd => "${buildmaster::settings::queue_dir}/tools",
            user => $users::builder::username,
            group => $users::builder::group;
    }
}
