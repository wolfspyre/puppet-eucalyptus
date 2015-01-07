class eucalyptus::drbd_config {
  # Ensure master drbd.conf refers to Eucalyptus config
  file_line { 'drbd master config entry':
    ensure  => present,
    line    => 'include "/etc/eucalyptus/drbd.conf";',
    path    => '/etc/drbd.conf',
    require => Package['drbd'],
  }
  package { 'drbd83-utils':
    ensure => present,
    alias  => 'drbd',
  }
  package { 'kmod-drbd83':
    ensure => present,
    alias  => 'drbd-kmod',
  }
  # Load kernel module, requires kern_module.pp
  eucalyptus::kern_module { 'drbd':
    ensure  => present,
    require => Package['drbd-kmod'],
  }

# Tell Eucalyptus.conf that we're using DRBD
# We can only declare eucalyptus::conf once,
# we need to split the provider so it can take separate options
# For now, it is a known limitation that the inclusion of this class alone isn't
# sufficient. You must also have the cloud_opts param to eucalyptus::conf
# populated thusly (at least)
#
#   class { 'eucalyptus::conf':
#    cloud_opts => '-Dwalrus.storage.manager=DRBDStorageManager',
#    }
#
# Hacky way of doing ths same thing:
#   file_line { 'cloud opts drbd entry':
#   ensure  => present,
#    line    => 'CLOUD_OPTS="-Dwalrus.storage.manager=DRBDStorageManager"',
#    path    => '/etc/eucalyptus/eucalyptus.conf',
#    notify  => Service["eucalyptus-cloud"],
#    require => eucalyptus::clc_install["eucalyptus-cloud"],
#  }
}
