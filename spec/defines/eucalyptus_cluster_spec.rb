#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::cluster', :type => :define do
  context 'input validation' do
      let (:title) { 'my_title'}
      let (:default_params) {{
        'cloud_name'=>"cloud1",
        'cluster_name'=>"cluster1"
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

    ['cloud_name','cluster_name'].each do |strings|
      context "when the #{strings} parameter is not a string" do
        let (:params) {default_params.merge({strings => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /is not a string./)
        end
      end
    end#strings

  end#input validation
  context "When on a RedHat system" do
    let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'redhat'}}
    context 'when fed sane parameters' do
      let (:title) { 'my_title'}
      let (:params) {{
        'cloud_name'=>"cloud1",
        'cluster_name'=>"cluster1"
        }}
      it 'should have some tests written at some point' do
        should contain_eucalyptus__cluster('my_title').with({:cloud_name=>"cloud1", :cluster_name=>"cluster1"})
        #p subject.resources
      end
    end#no params
  end
end
