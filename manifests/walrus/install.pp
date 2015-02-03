class eucalyptus::walrus::install {
  package { 'eucalyptus-walrus':
    ensure => present,
  }

  if !defined(Service['eucalyptus-cloud']) {
    service { 'eucalyptus-cloud':
      ensure  => running,
      enable  => true,
      require => Package['eucalyptus-walrus'],
    }
  }
}
