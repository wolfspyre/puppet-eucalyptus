class eucalyptus::cc (
  $cloud_name   = 'cloud1',
  $cluster_name = 'cluster1',
  ) {
    validate_string(
      $cloud_name,
      $cluster_name
    )
    include eucalyptus
    include eucalyptus::conf

    Class[eucalyptus] ->
    Class[eucalyptus::cc]

    Class[eucalyptus::repo]      ->
    Package[eucalyptus-cc]       ->
    Class[eucalyptus::cc::config] ->
    Eucalyptus_config<||>        ->
    Service[eucalyptus-cc]

    $registerif = regsubst($eucalyptus::conf::vnet_pubinterface, '\.', '_')
    $host = getvar("ipaddress_${registerif}")

    include eucalyptus::cc::install, eucalyptus::cc::config, eucalyptus::cc::reg
  }
