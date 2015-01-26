class eucalyptus::clc::config inherits eucalyptus::clc {
  Package['eucalyptus-cloud'] ->
  Eucalyptus_config <||> ->
  Exec['init-clc'] ->
  Service['eucalyptus-cloud'] ->
  Class[eucalyptus::clc::reg]
  $host         = $eucalyptus::clc::host
  $cloud_name   = $eucalyptus::clc::cloud_name
  # initializes some keys as well as the db
  exec { 'init-clc':
    command => '/usr/sbin/euca_conf --initialize',
    creates => '/var/lib/eucalyptus/db/data',
    timeout => '0',
  }

  # Cloud-wide
  if $::eucakeys_cloud_cert {
    @@file { "${cloud_name}_cloud_cert":
      path    => '/var/lib/eucalyptus/keys/cloud-cert.pem',
      content => base64('decode',$::eucakeys_cloud_cert),
      owner   => 'eucalyptus',
      group   => 'eucalyptus',
      mode    => '0700',
      tag     => "${cloud_name}_cloud_cert",
    }
  }
  if $::eucakeys_cloud_pk {
    @@file { "${cloud_name}_cloud_pk":
      path    => '/var/lib/eucalyptus/keys/cloud-pk.pem',
      content => base64('decode',$::eucakeys_cloud_pk),
      owner   => 'eucalyptus',
      group   => 'eucalyptus',
      mode    => '0700',
      tag     => "${cloud_name}_cloud_pk",
    }
  }

  # this resource is only required when the SC and CLC
  # aren't run from the same node
  if $::eucakeys_euca_p12 {
    @@file { "${cloud_name}_euca.p12":
      path  => '/var/lib/eucalyptus/keys/euca.p12',
      owner => 'eucalyptus',
      group => 'eucalyptus',
      mode  => '0700',
      tag   => "${cloud_name}_euca.p12",
    }

    # This is a hack to fix issues with shipping binary files with puppet
    # Its required both post puppetdb and ruby 1.9
    @@exec { "${cloud_name}_euca.p12":
      command => "/bin/echo \'${::eucakeys_euca_p12}\' | \
      /usr/bin/openssl base64 -d > /var/lib/eucalyptus/keys/euca.p12",
      unless  => '/usr/bin/test -s /var/lib/eucalyptus/keys/euca.p12',
      tag     => "${cloud_name}_euca.p12",
    }
  }
}
