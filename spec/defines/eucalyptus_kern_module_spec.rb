#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::kern_module', :type => :define do
  context 'input validation' do
    let (:title) { 'drbd'}
    let (:default_params) {{
      'ensure'   => 'present',
    }}
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

#    ['bool'].each do |bools|
#      context "when the #{bools} parameter is not an boolean" do
#        let (:params) {{bools => "BOGON"}}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /"BOGON" is not a boolean.  It looks to be a String/)
#        end
#      end
#    end#bools

#    ['hash'].each do |hashes|
#      context "when the #{hashes} parameter is not an hash" do
#        let (:params) {{ hashes => 'this is a string'}}
#        it 'should fail' do
#           expect { subject }.to raise_error(Puppet::Error, /is not a Hash./)
#        end
#      end
#    end#hashes

    ['ensure'].each do |regex|
      context "when #{regex} has an unsupported value" do
        let (:params) {{regex => 'BOGON'}}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /"BOGON" does not match/)
        end
      end
     end#regexes

#    [ 'string' ].each do |strings|
#      context "when the #{strings} parameter is not a string" do
#        let (:params) {default_params.merge({strings => ['bogon'] })}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /It looks to be a Array/)
#        end
#      end
#    end#strings
#    ['tries','try_sleep'].each do |int|
#      context "when #{int} has a value that is not an integer" do
#        let (:title) { 'increase_vol_size' }
#        let (:params) {{
#          'property_name'  => 'cluster1.storage.maxvolumesizeingb',
#          'property_value' => '15',
#          int              => 'foo'
#        }}
#        it 'should fail' do
#          expect { subject }.to raise_error(Puppet::Error, /Not an integer: foo/)
#        end
#      end
#    end
  end#input validation
  let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'redhat'}}
  context 'when fed enabling parameters' do
    let (:title) { 'drbd' }
    let (:params) {{ 'ensure'  => 'present',}}
    it{
      should contain_exec('insert_module_drbd').with({
        :command=>"/sbin/modprobe drbd",
        :unless=>"/bin/grep -q '^drbd ' '/proc/modules'"
      })
    }
    it {
      should_not contain_exec('remove_module_drbd')
    }
  end#sane
  context 'when fed disabling parameters' do
    let (:title) { 'drbd' }
    let (:params) {{ 'ensure'  => 'absent',}}
    it {
      should_not contain_exec('insert_module_drbd')
    }
    it{
      should contain_exec('remove_module_drbd').with({
        :command=>"/sbin/modprobe -r drbd",
        :onlyif=>"/bin/grep -q '^drbd ' '/proc/modules'"
      })
    }
  end#sane
  context 'when fed insane parameters' do
    let (:title) { 'drbd' }
    let (:params) {{ 'ensure'  => 'delicious',}}
    it 'should fail' do
      expect { subject }.to raise_error(Puppet::Error, /"delicious" does not match/)
    end
  end#sane
end
