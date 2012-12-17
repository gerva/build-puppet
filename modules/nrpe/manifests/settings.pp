class nrpe::settings {
    include ::shared
    $plugins_dir = "/usr/${::shared::lib_arch_dir}/nagios/plugins"
    $nrpe_etcdir = '/etc/nagios/'
}
