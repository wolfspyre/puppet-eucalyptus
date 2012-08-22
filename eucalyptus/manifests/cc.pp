class eucalyptus::cc ($cloud_name = "cloud1", $cluster_name = "cluster1" ) {

  Class['eucalyptus'] -> Class[eucalyptus::cc]

  include eucalyptus::conf

  class eucalyptus::cc_install {
    package { 'eucalyptus-cc':
      ensure => present,
    }
    service { 'eucalyptus-cc':
      ensure => running,
      enable => true,
    }
  }

  class eucalyptus::cc_config {
    File <<|title == "${cloud_name}-cloud-cert"|>>
    File <<|title == "${cloud_name}-cloud-pk"|>>
    File <<|title == "${cloud_name}-${cluster_name}-cc-cert"|>>
    File <<|title == "${cloud_name}-${cluster_name}-cc-pk"|>>
    File <<|title == "${cloud_name}-${cluster_name}-nc-cert"|>>
    File <<|title == "${cloud_name}-${cluster_name}-nc-pk"|>>
    Package[eucalyptus-cc] -> Eucalyptus_config<||> -> Service[eucalyptus-cc]
    Eucalyptus_config <||>
  }

  class eucalyptus::cc_reg {
    Class[eucalyptus::cc_reg] -> Class[eucalyptus::cc_config]
    @@exec { "reg_cc_${hostname}":
      command => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync --register-cluster --partition $cluster_name --host $ipaddress --component cc_$hostname",
      unless  => "/usr/sbin/euca_conf --list-clusters | /bin/grep -q '\b$ipaddress\b'",
      tag => "${cloud_name}",
    }
    # Register NC's from CC
    Exec <<|tag == "${cloud_name}_${cluster_name}_reg_nc"|>>
  }

  include eucalyptus::cc_install, eucalyptus::cc_config, eucalyptus::cc_reg
}
