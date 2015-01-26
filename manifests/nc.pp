class eucalyptus::nc (
  $cloud_name   = 'cloud1',
  $cluster_name = 'cluster1'
) {
  validate_string($cloud_name, $cluster_name)

  include eucalyptus
  include eucalyptus::conf
  Class['eucalyptus'] -> Class['eucalyptus::nc']

  Class['eucalyptus::repo']       ->
  Package['eucalyptus-nc']        ->
  Class['eucalyptus::nc::config'] ->
  Eucalyptus_config<||>           ->
  Service['eucalyptus-nc']

  $registerif = regsubst($eucalyptus::conf::vnet_pubinterface, '\.', '_')
  $host = getvar("ipaddress_${registerif}")

  include eucalyptus::nc::install, eucalyptus::nc::config, eucalyptus::nc::reg
}
