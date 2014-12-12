#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'
describe 'eucalyptus::arbitrator', :type => :define do
  context 'input validation' do
    let (:title) { 'my_title'}
    let (:default_params) {{
      'gateway_host'   => '192.168.0.1',
      'partition_name' => 'clc_arbitrator01',
      'service_host'   => '192.168.0.50',
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

    #    ['regex'].each do |regex|
    #      context "when #{regex} has an unsupported value" do
    #        let (:params) {{regex => 'BOGON'}}
    #        it 'should fail' do
    #          expect { subject }.to raise_error(Puppet::Error, /"BOGON" does not match/)
    #        end
    #      end
    #     end#regexes

    [
      'gateway_host',
      'partition_name',
      'service_host',
    ].each do |strings|
      context "when the #{strings} parameter is not a string" do
        let (:params) {default_params.merge({strings => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /It looks to be a Array/)
        end
      end
    end#strings
  end#input validation
  context "When on a rhel system" do
    let (:facts) {{'osfamily' => 'RedHat'}}
    context 'when fed no parameters' do
      let (:title) { 'my_title'}
      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /Must pass .* to Eucalyptus::Arbitrator/)
      end
    end#no params
    context 'when fed sane default parameters' do
      let (:title) { 'my_title'}
      let (:params) {{
        'gateway_host'   => '192.168.0.1',
        'partition_name' => 'clc_arbitrator01',
        'service_host'   => '192.168.0.50',
      }}
      it do
        should contain_eucalyptus__cloud_properties('arbitrator_gateway_clc_arbitrator01').with({
          :name=>"arbitrator_gateway_clc_arbitrator01",
          :property_name=>"clc_arbitrator01.arbitrator.gatewayhost",
          :property_value=>"192.168.0.1"
        })

        should contain_exec('cloud_property_clc_arbitrator01.arbitrator.gatewayhost').with({
          :command=>"/usr/sbin/euca-modify-property -p clc_arbitrator01.arbitrator.gatewayhost=192.168.0.1",
          :unless=>"/usr/sbin/euca-describe-properties | /bin/grep -i 'clc_arbitrator01.arbitrator.gatewayhost' | /bin/grep -qi '192.168.0.1'",
          :tries=>"3",
          :try_sleep=>"2"
        })
      end
    end
  end
end
