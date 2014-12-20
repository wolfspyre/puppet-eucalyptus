#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::repo', :type => :class do
  context 'input validation' do
    let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'redhat'}}

#    ['path'].each do |paths|
#      context "when the #{paths} parameter is not an absolute path" do
#        let (:params) {{ paths => 'foo' }}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /"foo" is not an absolute path/)
#        end
#      end
#    end#absolute path

#    ['array'].each do |arrays|
#      context "when the #{arrays} parameter is not an array" do
#        let (:params) {{ arrays => 'this is a string'}}
#        it 'should fail' do
#           expect { subject }.to raise_error(Puppet::Error, /is not an Array./)
#        end
#      end
#    end#arrays

    [
      'epel_repo_enable',
      'euca_repo_enable',
      'euca2ools_repo_enable',
      'manage_repos',
    ].each do |bools|
      context "when the #{bools} parameter is not an boolean" do
        let (:params) {{bools => "BOGON"}}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /"BOGON" is not a boolean.  It looks to be a String/)
        end
      end
    end#bools

#    ['hash'].each do |hashes|
#      context "when the #{hashes} parameter is not an hash" do
#        let (:params) {{ hashes => 'this is a string'}}
#        it 'should fail' do
#           expect { subject }.to raise_error(Puppet::Error, /is not a Hash./)
#        end
#      end
#    end#hashes

#    ['opt_hash'].each do |opt_hashes|
#      context "when the optional param #{opt_hashes} parameter has a value, but not a hash" do
#        let (:params) {{ hashes => 'this is a string'}}
#        it 'should fail' do
#           expect { subject }.to raise_error(Puppet::Error, /is not a Hash./)
#        end
#      end
#    end#opt_hashes

#    ['regex'].each do |regex|
#      context "when #{regex} has an unsupported value" do
#        let (:params) {{regex => 'BOGON'}}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /"BOGON" does not match/)
#        end
#      end
#     end#regexes

#    ['string'].each do |strings|
#      context "when the #{strings} parameter is not a string" do
#        let (:params) {{strings => false }}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /false is not a string./)
#        end
#      end
#    end#strings

#    ['opt_strings'].each do |optional_strings|
#      context "when the optional parameter #{optional_strings} has a value, but it is not a string" do
#        let (:params) {{optional_strings => true }}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /true is not a string./)
#        end
#      end
#    end#opt_strings

  end#input validation
  ['redhat','centos'].each do |os|
    context "When on a #{os} system" do
      let (:facts) {{'operatingsystem' => os}}
      context 'when fed no parameters' do
        it 'should lay down the gpg key' do
          should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release').with({
            :path=>"/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release",
            :ensure=>"present",
            :mode=>"0644",
            :owner=>"root",
            :group=>"root",
            :source=>"puppet:///modules/eucalyptus/c1240596-eucalyptus-release-key.pub"
          })
        end
        it 'should add the eucalyptus repo' do
          should contain_yumrepo('eucalyptus').with({
            :ensure=>"present",
            :descr=>"Eucalyptus 4.0",
            :enabled=>"1",
            :mirrorlist=>"http://mirrors.eucalyptus.com/mirrors?product=eucalyptus&distro=centos&releasever=\\$releasever&basearch=\\$basearch&version=4.0",
            :gpgkey=>"file:///etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release"
          }).that_requires('File[/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release]')
          should contain_file('/etc/yum.repos.d/eucalyptus.repo').with({
            :ensure => 'present'
          })
        end
        it 'should add the euca2ools repo' do
          should contain_yumrepo('euca2ools').with({
            :name=>"euca2ools",
            :ensure=>"present",
            :descr=>"Euca2ools 3.1",
            :enabled=>"1",
            :mirrorlist=>"http://mirrors.eucalyptus.com/mirrors?product=euca2ools&distro=centos&releasever=$releasever&basearch=$basearch&version=3.1",
            :gpgkey=>"/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release"
          }).that_requires('File[/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release]')
          should contain_file('/etc/yum.repos.d/euca2ools.repo').with({
            :ensure => 'present'
          })
        end

        it 'should contain the euca_epel repo' do
          should contain_yumrepo('euca_epel').with({
            :name=>"euca_epel",
            :ensure=>"present",
            :descr=>"epel",
            :enabled=>"1",
            :enablegroups=>"0",
            :gpgcheck=>"1",
            :gpgkey=>"http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6",
            :mirrorlist=>"https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch"
          })
          should contain_file('/etc/yum.repos.d/euca_epel.repo').with({
            :ensure => 'present'
          })
        end
      end#no params

      context 'when epel_repo_enable is false' do
        let (:params) {{'epel_repo_enable' => false}}
        it 'should remove the euca_epel repo' do
          should contain_yumrepo('euca_epel').with({
            :name=>"euca_epel",
            :ensure=>"absent",
            :descr=>"epel",
            :enabled=>"1",
            :enablegroups=>"0",
            :gpgcheck=>"1",
            :gpgkey=>"http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6",
            :mirrorlist=>"https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch"
          })
          should contain_file('/etc/yum.repos.d/euca_epel.repo').with({
            :ensure => 'absent'
          })
        end
      end

      context 'when euca2ools_repo_enable is false' do
        let (:params) {{'euca2ools_repo_enable' => false}}
        it 'should remove the euca2ools repo' do
          should contain_yumrepo('euca2ools').with({
            :name=>"euca2ools",
            :ensure=>"absent",
            :descr=>"Euca2ools 3.1",
            :enabled=>"1",
            :mirrorlist=>"http://mirrors.eucalyptus.com/mirrors?product=euca2ools&distro=centos&releasever=$releasever&basearch=$basearch&version=3.1",
            :gpgkey=>"/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release"
            }).that_requires('File[/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release]')
          should contain_file('/etc/yum.repos.d/euca2ools.repo').with({
            :ensure => 'absent'
          })
        end
      end

      context 'when euca_repo_enable is false' do
        let (:params) {{'euca_repo_enable' => false}}
        it 'should remove the eucalyptus repo' do
          should contain_yumrepo('eucalyptus').with({
            :ensure=>"absent",
            :descr=>"Eucalyptus 4.0",
            :enabled=>"1",
            :mirrorlist=>"http://mirrors.eucalyptus.com/mirrors?product=eucalyptus&distro=centos&releasever=\\$releasever&basearch=\\$basearch&version=4.0",
            :gpgkey=>"file:///etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release"
            }).that_requires('File[/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release]')
            should contain_file('/etc/yum.repos.d/eucalyptus.repo').with({
              :ensure => 'absent'
              })
            end
      end

      context 'when manage_repos is false' do
        let (:params) {{'manage_repos' => false}}
        it 'should not lay down the gpg key' do
          should_not contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-eucalyptus-release')
        end
        it 'should not add the eucalyptus repo' do
          should_not contain_yumrepo('eucalyptus')
          should_not contain_file('/etc/yum.repos.d/eucalyptus.repo')
        end
        it 'should not add the euca2ools repo' do
          should_not contain_yumrepo('euca2ools')
          should_not contain_file('/etc/yum.repos.d/euca2ools.repo')
        end
        it 'should not contain the euca_epel repo' do
          should_not contain_yumrepo('euca_epel')
          should_not contain_file('/etc/yum.repos.d/euca_epel.repo')
        end
      end#end manage_repos false

    end
  end
end
