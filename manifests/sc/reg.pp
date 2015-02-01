class eucalyptus::sc::reg inherits eucalyptus::sc {
  $cloud_name   = $eucalyptus::sc::cloud_name
  $cluster_name = $eucalyptus::sc::cluster_name

  Class[eucalyptus::sc::reg] -> Class[eucalyptus::sc::config]

  @@exec { "${cluster_name}_reg_sc_${::hostname}":
    command  => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync --register-sc \
 --partition ${cluster_name} --host ${host} --component sc_${::hostname}",
    unless   => "/usr/sbin/euca_conf --list-scs | \
    /bin/grep '\b${host}\b'",
    tag      => $cloud_name,
  }
}
