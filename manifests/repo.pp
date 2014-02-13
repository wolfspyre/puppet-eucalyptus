# This class sets up the repos for Eucalyptus and dependencies.
#
# == Parameters
#
# [*version*] The version of Eucalyptus we are installing. Defaults to 3.1.
#
# == Authors
#
# Teyo Tyree <teyo@puppetlabs.com\>
# David Kavanagh <david.kavanagh@eucalyptus.com\>
# Tom Ellis <tom.ellis@eucalyptus.com\>
# Olivier Renault <olivier.renault@eucalyptus.com\>
#
# == Copyright
#
# Copyright 2012 Eucalyptus INC under the Apache 2.0 license
#

class eucalyptus::repo {
  # Check which OS we are installing on
  case $operatingsystem  {
    # there should a way to distinguish
    redhat, centos : {
      file { '/etc/pki/rpm-gpg/eucalyptus-release.pub':
        ensure => present,
        mode   => '0644',
        owner  => root,
        group  => root,
        source => 'puppet:///modules/eucalyptus/c1240596-eucalyptus-release-key.pub',
      }
      yumrepo { "Eucalyptus-repo":
        name    => "eucalyptus",
        descr   => "Eucalyptus Repository",
        enabled => 1,
        baseurl => "http://downloads.eucalyptus.com/software/eucalyptus/3.3/rhel/\$releasever/\$basearch",
        gpgkey  => 'file:///etc/pki/rpm-gpg/eucalyptus-release.pub',
        require => File['/etc/pki/rpm-gpg/eucalyptus-release.pub'],
      }
      yumrepo { "Euca2ools-repo":
        name    => "euca2ools",
        descr   => "Euca2ools Repository",
        enabled => 1,
        baseurl => "http://downloads.eucalyptus.com/software/euca2ools/3.0/rhel/\$releasever/\$basearch",
        gpgkey  => 'file:///etc/pki/rpm-gpg/eucalyptus-release.pub',
        require => File['/etc/pki/rpm-gpg/eucalyptus-release.pub'],
      }
    }
    ubuntu : {
      file { '/etc/apt/trusted.gpg.d/eucalyptus-release.gpg':
        ensure => present,
        mode   => '0644',
        owner  => root,
        group  => root,
        source => 'puppet:///modules/eucalyptus/c1240596-eucalyptus-release-key.gpg',
      }
      apt::source { 'eucalyptus':
        location => 'http://downloads.eucalyptus.com/software/eucalyptus/3.1/ubuntu',
        repos    => 'main',
        require  => File['/etc/apt/trusted.gpg.d/eucalyptus-release.gpg'],
      }
    }
    default : {
      fail("${::operatingsystem} is not a supported operating system")
    }
  }
}

class eucalyptus::extrarepo {
  case $operatingsystem  {
    centos, redhat : {
      # Install other repository required for Eucalyptus
      # Eucalyptus is keeping a copy of their repository RPM
      # So we can install their repo package directly from Eucalyptus repo
      $repo_packages = ['elrepo-release', 'epel-release']
        package { $repo_packages:
          ensure  => latest,
          require => Class[eucalyptus::repo],
      }
    }
  }
}
