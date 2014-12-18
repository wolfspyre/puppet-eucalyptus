#
class eucalyptus::cc::reg inherits eucalyptus::cc {
  Class[eucalyptus::cc::config] -> Class[eucalyptus::cc::reg]

  @@exec { "reg_cc_${::hostname}":
    command  => "/usr/sbin/euca_conf --no-rsync --no-scp --no-sync \
  --register-cluster --partition ${cluster_name} --host ${host} \
  --component cc_${::hostname}",
    unless   => "/usr/sbin/euca_conf --list-clusters | /bin/grep -q '\b${host}\b'",
    tag      => $cloud_name,
  }
}
