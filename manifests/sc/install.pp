class eucalyptus::sc::install {
  package { 'eucalyptus-sc':
    ensure => present,
  }
  if !defined(Service['eucalyptus-cloud']) {
    service { 'eucalyptus-cloud':
      ensure  => running,
      enable  => true,
      require => Package['eucalyptus-sc'],
    }
  }
}
