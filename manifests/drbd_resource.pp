# DRBD Resource to be used in conjunction with Eucalyptus Walrus HA
#
# == Parameters
# [host1] - primary walrus host
# [host2] - secondary walrus host
# [ip1] - IP address of primary walrus
# [ip2] - IP address of secondary walrus
# [disk_host1] - disk/partition to use for walrus on host1
# [disk_host2] - disk/partition to use for walrus on host2
#
# == Authors
# Tom Ellis <tom.ellis@eucalyptus.com\>
# Inspired by: https://github.com/camptocamp/puppet-drbd/

define eucalyptus::drbd_resource(
  $host1,
  $host2,
  $ip1,
  $ip2,
  $disk_host1,
  $disk_host2,
  $port='7789',
  $rate='40M',
  $manage=true,
  $device='/dev/drbd1',
) {
  validate_absolute_path(
    $device,
    $disk_host1,
    $disk_host2,
  )
  validate_bool(
    $manage
  )
  validate_string(
    $host1,
    $host2,
    $ip1,
    $ip2,
    $port,
    $rate,
  )
  if $manage {
    # We should only do anything if manage is true

    # Ensure drbd packages and config is ready
    include eucalyptus::drbd_config

    file { "eucalyptus_drbd_resource_${name}":
      content => template('eucalyptus/eucalyptus_drbd.drbd.conf.erb'),
      path    => '/etc/eucalyptus/drbd.conf',
      require => [ Package['drbd'], Kern_module['drbd'], ],
    }
    # Determine which host we are, and in turn which $disk_host parameter to use
    case $::fqdn {
      $host1: { $disk = $disk_host1 }
      $host2: { $disk = $disk_host2 }
      default: { fail("Unrecognized host, make sure the fqdn ${::fqdn} matches the host defined in the drbd resource") }
    }
    # create metadata on device, except if resource seems already initalized.
    exec { "intialize DRBD metadata for ${name}":
      command => "/sbin/drbdmeta --force ${device} v08 ${disk} internal create-md",
      onlyif  => "/usr/bin/test -e ${disk}",
      # Don't try to init if syncing, connecting or if split-brain
      unless  => "/sbin/drbdadm cstate ${name} | /bin/egrep -q '^(Sync|Connected|WFConnection)'",
      require => [ Kern_module["drbd"], File["eucalyptus_drbd_resource_${name}"], ]
    }
    exec { "enable DRBD resource ${name}":
      # bring device up (a shortcut for attach & connect)
      command => "/sbin/drbdadm up ${name}" ,
      onlyif  => "/sbin/drbdadm dstate ${name} | /bin/egrep -q '^Diskless/|^Unconfigured'",
      require => [ Exec["intialize DRBD metadata for ${name}"], Kern_module['drbd'], ],
    }
  }
}
