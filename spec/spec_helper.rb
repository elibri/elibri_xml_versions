require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'ostruct'
require 'mocha'
require 'elibri_xml_versions' # and any other gems you need
require 'support/mocks/xml_mocks'
require 'support/mocks/mock_method_missing'
require 'support/generators/xml_generator'
require 'support/xml_variant'
require 'support/onix_helpers'



require 'ruby-debug'


RSpec.configure do |config|
  # some (optional) config here
end

def onix_from_mock(sym, options = {})
  Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(ONIX::XMLGenerator.new(XmlMocks::Examples.send(sym, options)).to_s)
end
