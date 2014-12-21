#!/usr/bin/env rspec
require 'spec_helper'
require 'pry'

describe 'eucalyptus::cloud_properties', :type => :define do
  context 'input validation' do
    let (:title) { 'increase_vol_size'}
    let (:default_params) {{
      'property_name'   => 'cluster1.storage.maxvolumesizeingb',
      'property_value' => '15',
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
      'property_name',
      'property_value',
      'tries',
      'try_sleep',
    ].each do |strings|
      context "when the #{strings} parameter is not a string" do
        let (:params) {default_params.merge({strings => ['bogon'] })}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /It looks to be a Array/)
        end
      end
    end#strings
    ['tries','try_sleep'].each do |int|
      context "when #{int} has a value that is not an integer" do
        let (:title) { 'increase_vol_size' }
        let (:params) {{
          'property_name'  => 'cluster1.storage.maxvolumesizeingb',
          'property_value' => '15',
          int              => 'foo'
        }}
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /Not an integer: foo/)
        end
      end
    end
  end#input validation
  let (:facts) {{'osfamily' => 'RedHat', 'operatingsystem' => 'redhat'}}
  context 'when fed sane parameters' do
    let (:title) { 'increase_vol_size' }
    let (:params) {{
      'property_name'  => 'cluster1.storage.maxvolumesizeingb',
      'property_value' => '15',
    }}
    it{
      should contain_exec('cloud_property_cluster1.storage.maxvolumesizeingb').with({
        :command=>"/usr/sbin/euca-modify-property -p cluster1.storage.maxvolumesizeingb=15",
        :unless=>"/usr/sbin/euca-describe-properties | /bin/grep -i 'cluster1.storage.maxvolumesizeingb' | /bin/grep -qi '15'",
        :tries=>"3",
        :try_sleep=>"2"
      })
    }
  end#sane
  ['cluster1.storage.maxvolumesizeingb', 'someotherproperty'].each do |propertyname|
    ['10','20','blah',99].each do |propertyvalue|
      ['tries','try_sleep'].each do |try|
        ['1',"2",3].each do |val|
          context "value iterator:" do
            let (:title) { "#{propertyname}_#{propertyvalue}" }
            let (:params) {{
              'property_name'  => propertyname,
              'property_value' => propertyvalue,
              try              => val
            }}

            it "#{propertyname} (#{propertyvalue}) #{try} (#{val})" do
              should contain_exec("cloud_property_#{propertyname}").with({
                :command=>"/usr/sbin/euca-modify-property -p #{propertyname}=#{propertyvalue}",
                :unless=>"/usr/sbin/euca-describe-properties | /bin/grep -i '#{propertyname}' | /bin/grep -qi '#{propertyvalue}'",
                try=>val,
              })
            end
          end#context
        end#val_iter
      end#try_iter
    end#propval_iter
  end#propname_iter
end
