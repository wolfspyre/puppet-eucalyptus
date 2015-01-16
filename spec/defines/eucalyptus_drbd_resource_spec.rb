#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::drbd_resource', :type => :define do
  context 'input validation' do
    let (:title) { 'my_title'}
    let (:default_params) {{
      'host1'      => 'walrus1.example.com',
      'host2'      => 'walrus2.example.com',
      'ip1'        => '10.0.0.1',
      'ip2'        => '10.0.0.2',
      'disk_host1' => '/dev/blockdev/sda1_on_host1',
      'disk_host2' => '/dev/blockdev/sda1_on_host2',
      'port'       => '7789',
      'rate'       => '40M',
      'manage'     => true,
      'device'     => '/dev/drbd1',
    }}
    [
      'device',
      'disk_host1',
      'disk_host2',
    ].each do |paths|
      context "when the #{paths} parameter is not an absolute path" do
        let (:params) {default_params.merge({paths => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /"bogon" is not an absolute path/)
        end
      end
    end#absolute path

#    ['array'].each do |arrays|
#      context "when the #{arrays} parameter is not an array" do
#        let (:params) {{ arrays => 'this is a string'}}
#        it 'should fail' do
#           expect { subject }.to raise_error(Puppet::Error, /is not an Array./)
#        end
#      end
#    end#arrays

    ['manage'].each do |bools|
      context "when the #{bools} parameter is not an boolean" do
        let (:params) {default_params.merge({bools => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /is not a boolean.  It looks to be a Array/)
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

#    ['regex'].each do |regex|
#      context "when #{regex} has an unsupported value" do
#        let (:params) {{regex => 'BOGON'}}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /"BOGON" does not match/)
#        end
#      end
#     end#regexes

    [
      'host1',
      'host2',
      'ip1',
      'ip2',
      'port',
      'rate',
    ].each do |strings|
      context "when the #{strings} parameter is not a string" do
        let (:params) {default_params.merge({strings => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /is not a string.  It looks to be a Array/)
        end
      end
    end#strings

  end#input validation
  context "When on a RedHat system" do
    let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'bogonsystems1.tastybacon.com' }}
    let (:default_params) {{
      'host1'      => 'walrus1.example.com',
      'host2'      => 'walrus2.example.com',
      'ip1'        => '10.0.0.1',
      'ip2'        => '10.0.0.2',
      'disk_host1' => '/dev/blockdev/sda1_on_host1',
      'disk_host2' => '/dev/blockdev/sda1_on_host2',
      'port'       => '7789',
      'rate'       => '40M',
      'manage'     => true,
      'device'     => '/dev/drbd1',
      }}
    context 'when fed sane parameters' do
      context 'but ::fqdn matches neither host1 nor host2' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'bogonsystems1.tastybacon.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /Unrecognized host,/)
        end
      end
      context 'as host1' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'walrus1.example.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params}
        #it 'provide a generated catalog for testbuilding' do
        #  binding.pry;
        #end
        it do
          should contain_class('eucalyptus::drbd_config')
        end
        it 'should initialize the eucalyptus_drbd_resource file resource which populates /etc/eucalyptus/drbd.conf' do
          should contain_file('eucalyptus_drbd_resource_my_title').with({
            :path=>"/etc/eucalyptus/drbd.conf"
          }).with_content(
          /resource my_title/,
          /on walrus1.example.com/,
          /device    \/dev\/drbd1/,
          /disk      \/dev\/blockdev\/sda1_on_host1;/,
          /address   10.0.0.1:7789;/,
          /meta-disk internal;/,
          /on walrus2.example.com/,
          /device    \/dev\/drbd1/,
          /disk      \/dev\/blockdev\/sda1_on_host2;/,
          /address   10.0.0.2:7789;/,
          /meta-disk internal;/,
          /syncer/,
          /rate 40M;/,
          /net/,
          /after-sb-0pri discard-zero-changes;/,
          /after-sb-1pri discard-secondary/,
          )
        end

        it 'should initialize the drbd metadata' do
          should contain_exec('intialize DRBD metadata for my_title').with({
            :command=>"/sbin/drbdmeta --force /dev/drbd1 v08 /dev/blockdev/sda1_on_host1 internal create-md",
            :onlyif=>"/usr/bin/test -e /dev/blockdev/sda1_on_host1",
            :unless=>"/sbin/drbdadm cstate my_title | /bin/egrep -q '^(Sync|Connected|WFConnection)'"
          }).that_requires('Eucalyptus::Kern_module[drbd]').that_requires('File[eucalyptus_drbd_resource_my_title]')
        end
        it 'should enable the drbd resource' do
          should contain_exec('enable DRBD resource my_title').with({
            :command=>"/sbin/drbdadm up my_title",
            :onlyif=>"/sbin/drbdadm dstate my_title | /bin/egrep -q '^Diskless/|^Unconfigured'",
          }).that_requires('Exec[intialize DRBD metadata for my_title]').that_requires('eucalyptus::Kern_module[drbd]')
        end
      end
      context 'as host2' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'walrus2.example.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params}
        #it 'provide a generated catalog for testbuilding' do
        #  binding.pry;
        #end
        it do
          should contain_class('eucalyptus::drbd_config')
        end
        it 'should initialize the eucalyptus_drbd_resource file resource which populates /etc/eucalyptus/drbd.conf' do
          should contain_file('eucalyptus_drbd_resource_my_title').with({
            :path=>"/etc/eucalyptus/drbd.conf"
          }).with_content(
            /resource my_title/,
            /on walrus1.example.com/,
            /device    \/dev\/drbd1/,
            /disk      \/dev\/blockdev\/sda1_on_host1;/,
            /address   10.0.0.1:7789;/,
            /meta-disk internal;/,
            /on walrus2.example.com/,
            /device    \/dev\/drbd1/,
            /disk      \/dev\/blockdev\/sda1_on_host2;/,
            /address   10.0.0.2:7789;/,
            /meta-disk internal;/,
            /syncer/,
            /rate 40M;/,
            /net/,
            /after-sb-0pri discard-zero-changes;/,
            /after-sb-1pri discard-secondary/,
          )
        end

        it 'should initialize the drbd metadata' do
          should contain_exec('intialize DRBD metadata for my_title').with({
            :command=>"/sbin/drbdmeta --force /dev/drbd1 v08 /dev/blockdev/sda1_on_host2 internal create-md",
            :onlyif=>"/usr/bin/test -e /dev/blockdev/sda1_on_host2",
            :unless=>"/sbin/drbdadm cstate my_title | /bin/egrep -q '^(Sync|Connected|WFConnection)'"
          }).that_requires('Eucalyptus::Kern_module[drbd]').that_requires('File[eucalyptus_drbd_resource_my_title]')
        end
        it 'should enable the drbd resource' do
          should contain_exec('enable DRBD resource my_title').with({
            :command=>"/sbin/drbdadm up my_title",
            :onlyif=>"/sbin/drbdadm dstate my_title | /bin/egrep -q '^Diskless/|^Unconfigured'",
          }).that_requires('Exec[intialize DRBD metadata for my_title]').that_requires('eucalyptus::Kern_module[drbd]')
        end
      end
    end#sane params
    context 'when manage is false' do
      context 'on an irrelevant host' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'bogonhost.example.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params.merge({'manage' => false})}
        it { should_not contain_class('eucalyptus::drbd_config') }
        it { should_not contain_file('eucalyptus_drbd_resource_my_title') }
        it { should_not contain_exec('enable DRBD resource my_title') }
        it { should_not contain_exec('intialize DRBD metadata for my_title')}
      end
      context 'on host1' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'walrus1.example.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params.merge({'manage' => false})}
        it { should_not contain_class('eucalyptus::drbd_config') }
        it { should_not contain_file('eucalyptus_drbd_resource_my_title') }
        it { should_not contain_exec('enable DRBD resource my_title') }
        it { should_not contain_exec('intialize DRBD metadata for my_title') }
      end
      context 'on host2' do
        let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'centos', 'fqdn' => 'walrus2.example.com'}}
        let (:title) { 'my_title'}
        let (:params) {default_params.merge({'manage' => false})}
        it { should_not contain_class('eucalyptus::drbd_config') }
        it { should_not contain_file('eucalyptus_drbd_resource_my_title') }
        it { should_not contain_exec('enable DRBD resource my_title') }
        it { should_not contain_exec('intialize DRBD metadata for my_title') }
      end
    end#manage false
  end
end
