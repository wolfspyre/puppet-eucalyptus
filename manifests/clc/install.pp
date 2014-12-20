class eucalyptus::clc::install {
  package { 'eucalyptus-cloud':
    ensure => present,
  }
  service { 'eucalyptus-cloud':
    ensure => running,
    enable => true,
  }
}
