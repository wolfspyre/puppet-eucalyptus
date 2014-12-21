class eucalyptus::clc2::install {
  package { 'eucalyptus-cloud':
    ensure => present,
  }
  service { 'eucalyptus-cloud':
    ensure  => running,
    enable  => true,
    require => Package['eucalyptus-cloud'],
  }
}
