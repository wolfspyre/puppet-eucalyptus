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

class eucalyptus::repo(
  $epel_repo_enable      = true,
  $euca2ools_repo_enable = true,
  $euca_repo_enable      = true,
  $manage_repos          = true,
  ) {
  validate_bool(
    $euca_repo_enable,
    $euca2ools_repo_enable,
    $epel_repo_enable,
    $manage_repos,
  )
  if $manage_repos {
    # Check which OS we are installing on
    case $::operatingsystem  {
      redhat, centos : {
        file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release':
          ensure => present,
          mode   => '0644',
          owner  => root,
          group  => root,
          source => 'puppet:///modules/eucalyptus/c1240596-eucalyptus-release-key.pub',
        }
        if $euca_repo_enable {
          $_euca_repo_ensure = 'present'
        } else {
          $_euca_repo_ensure = 'absent'
        }
        if $euca2ools_repo_enable {
          $_euca2ools_repo_ensure = 'present'
        } else {
          $_euca2ools_repo_ensure = 'absent'
        }
        if $epel_repo_enable {
          $_epel_repo_ensure = 'present'
        } else {
          $_epel_repo_ensure = 'absent'
        }
        yumrepo { 'eucalyptus':
          ensure     => $_euca_repo_ensure,
          name       => 'eucalyptus',
          descr      => 'Eucalyptus 4.0',
          enabled    => 1,
          mirrorlist => 'http://mirrors.eucalyptus.com/mirrors?product=eucalyptus&distro=centos&releasever=\$releasever&basearch=\$basearch&version=4.0',
          gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release',
          require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release'],
        }
        file {'/etc/yum.repos.d/eucalyptus.repo':
          ensure => $_euca_repo_ensure,
        }
        yumrepo { 'euca2ools':
          ensure     => $_euca2ools_repo_ensure,
          name       => 'euca2ools',
          descr      => 'Euca2ools 3.1',
          enabled    => 1,
          mirrorlist => 'http://mirrors.eucalyptus.com/mirrors?product=euca2ools&distro=centos&releasever=$releasever&basearch=$basearch&version=3.1',
          gpgkey     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release',
          require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release'],
        }
        file {'/etc/yum.repos.d/euca2ools.repo':
          ensure => $_euca2ools_repo_ensure,
        }
        yumrepo { 'euca_epel':
          ensure       => $_epel_repo_ensure,
          descr        => 'epel',
          enabled      => '1',
          enablegroups => '0',
          gpgcheck     => '1',
          gpgkey       => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
          mirrorlist   => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
        }
        file {'/etc/yum.repos.d/euca_epel.repo':
          ensure => $_epel_repo_ensure,
        }
      }#rhel case
      default : {
        fail("${::operatingsystem} is not a supported operating system")
      }#default case

    }#operatingsystem case
  }#manage_repos true
}
