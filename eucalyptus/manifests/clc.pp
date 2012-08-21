class eucalyptus::clc ($cloud_name = "cloud1") {
  include eucalyptus::conf
  include eucalyptus
  include eucalyptus::clc_install
  include eucalyptus::clc_config
  include eucalyptus::clc_reg
  Class[eucalyptus] -> Class[eucalyptus::clc]

  class eucalyptus::clc_install {
    package { 'eucalyptus-cloud':
      ensure => present,
    }
    service { 'eucalyptus-cloud':
      ensure => running,
      enable => true,
      require => Package['eucalyptus-cloud'],
    }
    
  }
  class eucalyptus::clc_config {
    Class[eucalyptus::clc_install] -> Class[eucalyptus::clc_config]
    Apt::Source<||> -> Package[eucalyptus-cloud] -> Eucalyptus_config<||> -> Service[eucalyptus-cloud]
    
    exec { 'init-db':
      command => "/usr/sbin/euca_conf --initialize",
      creates => "/var/lib/eucalyptus/db/data",
      timeout => "0",
    }

    # Cloud-wide
    @@file { "${cloud_name}-cloud-cert":
      path => '/var/lib/eucalyptus/keys/cloud-cert.pem',
      content => "$eucakeys_cloud_cert",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    @@file { "${cloud_name}-cloud-pk":
      path => '/var/lib/eucalyptus/keys/cloud-pk.pem',
      content => "$eucakeys_cloud_pk",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    @@file { "${cloud_name}-euca.p12":
      path => '/var/lib/eucalyptus/keys/euca.p12',
      content => "$eucakeys_euca_p12",
      owner  => 'eucalyptus',
      group  => 'eucalyptus',
      mode   => '0700',
      tag => "${cloud_name}",
    }
    
    Eucalyptus_config <||>
  }
  class eucalyptus::clc_reg {
    Class[eucalyptus::clc_reg] -> Class[eucalyptus::clc_config]
    Exec <<|tag == "$cloud_name"|>>
  }

  
}
