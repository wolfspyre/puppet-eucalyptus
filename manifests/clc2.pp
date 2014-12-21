class eucalyptus::clc2 ($cloud_name = "cloud1") {
  include eucalyptus
  include eucalyptus::conf
  Class['eucalyptus'] ->
    Class['eucalyptus::clc2']

  Class['eucalyptus::repo'] ->
    Package['eucalyptus-cloud'] ->
      Class['eucalyptus::clc2::config'] ->
        Eucalyptus_config<||> ->
          Service['eucalyptus-cloud']
  $registerif = regsubst($eucalyptus::conf::vnet_pubinterface, '\.', '_')
  $host       = getvar("ipaddress_${registerif}")
  include eucalyptus::clc2::install
  include eucalyptus::clc2::config
  include eucalyptus::clc2::reg
}
