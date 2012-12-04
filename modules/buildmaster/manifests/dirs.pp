class buildmaster::dirs {
    include buildmaster::settings
    file {
        [ "${buildmaster::settings::master_root}",
          "${buildmaster::settings::queue_dir}",
          "${buildmaster::settings::master_basedir}",
          "${buildmaster::settings::master_dir}",
        ],
        owner => $users::builder::username,
        group => $users::builder::group,
        ensure => directory,
        mode => 0755;
    }
}
