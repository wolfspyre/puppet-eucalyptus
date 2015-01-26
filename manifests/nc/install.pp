class eucalyptus::nc::install {
  package { 'eucalyptus-nc':
    ensure => present,
  }
  service { 'eucalyptus-nc':
    ensure => running,
    enable => true,
  }
}
