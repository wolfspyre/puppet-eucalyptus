require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec'
require 'puppet'
require 'rspec-puppet'
Puppet.settings[:confdir] = "spec/fixtures"
Puppet.settings[:hiera_config] = "spec/fixtures/hiera.yaml"


#PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
#$LOAD_PATH.unshift(File.join(PROJECT_ROOT, "lib"))
#
#fixture_path = File.expand_path(File.join('spec', 'fixtures'), PROJECT_ROOT)
#RSpec.configure do |config|
#  config.module_path = File.join(fixture_path, 'modules')
#  config.manifest_dir = File.join(fixture_path, 'manifests')
#end
