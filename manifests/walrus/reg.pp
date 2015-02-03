class eucalyptus::walrus::reg inherits eucalyptus::walrus {
  $host = $eucalyptus::walrus::host
  $cloud_name = $eucalyptus::walrus::cloud_name
  #TODO: make this exec export consistently named with other
  #execs relating to a specific cloud/cluster
  @@exec { "reg_walrus_${::hostname}":
    command => "/usr/sbin/euca_conf --no-rsync --no-scp \
    --no-sync --register-walrus --partition walrus \
    --host ${host} --component walrus_${::hostname}",
    unless  => "/usr/sbin/euca_conf --list-walruses | \
    /bin/grep '\b${host}\b'",
    tag     => $cloud_name,
  }
}
