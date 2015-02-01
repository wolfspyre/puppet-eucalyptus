class eucalyptus::sc (
  $cloud_name   = 'cloud1',
  $cluster_name = 'cluster1',
) {
  validate_string($cloud_name, $cluster_name)
  include eucalyptus
  include eucalyptus::conf
  Class[eucalyptus] -> Class[Eucalyptus::Conf] -> Class[eucalyptus::sc]

  Package[eucalyptus-sc]       ->
  Class[eucalyptus::sc::config] ->
  Eucalyptus_config<||>        ->
  Service[eucalyptus-cloud]

  $registerif = regsubst($eucalyptus::conf::vnet_pubinterface, '\.', '_')
  $host = getvar("ipaddress_${registerif}")



  include eucalyptus::sc::install, eucalyptus::sc::config, eucalyptus::sc::reg
}
