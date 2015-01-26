class eucalyptus::clc2::reg inherits eucalyptus::clc2 {
  $host       = $eucalyptus::clc2::host
  $cloud_name = $eucalyptus::clc2::cloud_name
  @@exec { "reg_clc_${::hostname}":
    command => "/usr/sbin/euca_conf \
    --no-rsync \
    --no-scp \
    --no-sync \
    --register-cloud \
    --partition eucalyptus \
    --host ${host} \
    --component clc_${::hostname}",
    unless => "/usr/sbin/euca_conf --list-clouds | \
    /bin/grep '\b${host}\b'",
    tag => $cloud_name,
  }
}
