#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::nc::reg', :type => :class do
  context 'input validation' do

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
  context "When on a RedHat system" do
    let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'redhat', 'hostname' => 'euca_nc_01', 'ipaddress_eth0' => '10.0.0.1'}}
    #TODO: set custom facts for eucakeys to permit testing of realization of exported file resources.
    let(:pre_condition) { ['Exec<||>','class{"eucalyptus::Clc": cloud_name => "cloud1", before =>"Class[Eucalyptus::nc]" }', 'eucalyptus::cluster{"mycluster": cloud_name => "cloud1", cluster_name => "cluster1"}' ] }
    it 'should export the exec which fires euca_conf' do
      should contain_exec('cluster1_reg_nc_euca_nc_01').with({
        :command=>"/usr/sbin/euca_conf --no-rsync --no-sync --no-scp  --register-nodes 10.0.0.1",
        :unless=>"/bin/grep -i '\\b10.0.0.1\\b' /etc/eucalyptus/eucalyptus.conf",
        :tag=>"cloud1_cluster1_reg_nc"
      })
    end
  end
end
