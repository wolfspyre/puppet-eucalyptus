#
class eucalyptus::cc::reg inherits eucalyptus::cc {
  Class[eucalyptus::cc::config] -> Class[eucalyptus::cc::reg]
  $cluster_name = $eucalyptus::cc::cluster_name
  $host         = $eucalyptus::cc::host
  $cloud_name   = $eucalyptus::cc::cloud_name
  @@exec { "reg_cc_${::hostname}":
    command => "/usr/sbin/euca_conf --no-rsync --no-sync --no-scp \
--register-cluster --partition ${cluster_name} --host ${host} \
--component cc_${::hostname}",
    unless  => "/usr/sbin/euca_conf --list-clusters | /bin/grep -q '\b${host}\b'",
    tag     => $cloud_name,
  }
}
