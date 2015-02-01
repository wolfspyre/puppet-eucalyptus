class eucalyptus::ntp {
  package { 'ntp': ensure => present }

  file { '/etc/ntp.conf':
    group   => 'root',
    mode    => '0644',
    notify  => Service['ntp'],
    owner   => 'root',
    require => Package['ntp'],
    source  => 'puppet:///modules/eucalyptus/ntp.conf',
  }

  service { 'ntpd':
    ensure => running,
    enable => true,
  }

}
