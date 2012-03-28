require 'rubygems'
require 'bundler/setup'

require 'elibri_xml_versions' # and any other gems you need
require 'mocha'
require 'elibri_api_client'
require 'elibri_onix_dict'
require 'support/mocks/xml_mocks'
require 'support/mocks/mock_method_missing'
require 'support/generators/xml_generator'
require 'support/xml_variant'
require 'support/onix_helpers'
require 'rspec'
require 'ostruct'

require 'ruby-debug'


RSpec.configure do |config|
  # some (optional) config here
end
