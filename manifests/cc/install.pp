#
class eucalyptus::cc::install {
  package { 'eucalyptus-cc':
    ensure => present,
  }
  service { 'eucalyptus-cc':
    ensure => running,
    enable => true,
  }
}
