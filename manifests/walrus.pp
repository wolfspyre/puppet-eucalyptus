class eucalyptus::walrus (
  $cloud_name = 'cloud1',
) {
  validate_string($cloud_name)
  include eucalyptus
  include eucalyptus::conf

  Class[eucalyptus] -> Class[eucalyptus::walrus]

  Class[eucalyptus::repo]           ->
  Package[eucalyptus-walrus]        ->
  Class[eucalyptus::walrus::config] ->
  Eucalyptus_config<||>             ->
  Service[eucalyptus-cloud]

  $registerif = regsubst($eucalyptus::conf::vnet_pubinterface, '\.', '_')
  $host       = getvar("ipaddress_${registerif}")
  include eucalyptus::walrus::install
  include eucalyptus::walrus::config
  include eucalyptus::walrus::reg
}
