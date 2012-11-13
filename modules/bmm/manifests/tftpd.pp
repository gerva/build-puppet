class bmm::tftpd {
    include ::tftpd

    file {
       "/var/lib/tftpboot/pxelinux.cfg":
            ensure => directory,
            # owned by apache so the CGI can write to it
            owner => apache,
            group => apache;
        "/var/lib/tftpboot/panda-live":
            ensure => directory;
        "/var/lib/tftpboot/panda-live/uImage":
            ensure => file,
            source => "puppet:///bmm/pxe/uImage";
        "/var/lib/tftpboot/panda-live/uInitrd":
            ensure => file,
            source => "puppet:///bmm/pxe/uInitrd";
    }
}
