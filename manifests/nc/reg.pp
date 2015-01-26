class eucalyptus::nc::reg inherits eucalyptus::nc {
  $cloud_name   = $eucalyptus::nc::cloud_name
  $host         = $eucalyptus::nc::host
  $cluster_name = $eucalyptus::nc::cluster_name
  #Eucalyptus_config <||> { notify => Service["eucalyptus-nc"] }
  # Causes too many service refreshes
  Eucalyptus_config <||>
  @@exec { "${cluster_name}_reg_nc_${::hostname}":
    command => "/usr/sbin/euca_conf --no-rsync --no-sync --no-scp \
 --register-nodes ${host}",
    unless  => "/bin/grep -i '\b${host}\b' /etc/eucalyptus/eucalyptus.conf",
    tag     => "${cloud_name}_${cluster_name}_reg_nc",
}
}
