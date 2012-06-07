require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'ostruct'
#require 'mocha'
require 'elibri_xml_versions' # and any other gems you need
require 'elibri_onix_mocks'
=begin
require 'support/mocks/xml_mocks'
require 'support/mocks/mock_method_missing'
require 'support/generators/xml_generator'
require 'support/xml_variant'
require 'support/onix_helpers'
=end




RSpec.configure do |config|
  # some (optional) config here
end

def onix_from_mock(sym, *args)
  Elibri::ONIX::Release_3_0::ONIXMessage.new(Elibri::ONIX::XMLGenerator.new(Elibri::XmlMocks::Examples.send(sym, *args)).to_s)
end

def xml_parse(xml_string)
  Elibri::ONIX::Release_3_0::ONIXMessage.new(xml_string)
end

def generate_xml(mock)
  Elibri::ONIX::XMLGenerator.new(mock)
end