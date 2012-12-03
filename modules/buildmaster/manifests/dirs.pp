class buildmaster::dirs {

    file {
        [ "${master_basedir}",
          "${master_dir}",
          "${master_dir}/${master_name}",
          "${master_dir}/${master_name}/${master_type}",
          "${queue_dir}",
        ]:
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => directory,
            mode => 0755;
    }
}
