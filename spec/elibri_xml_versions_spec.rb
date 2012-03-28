require 'spec_helper'

describe Elibri::XmlVersions do
  
  it "should return true for same elibri objects" do
    product = XmlMocks::Examples.basic_product
    xml = ONIX::XMLGenerator.new(product)
    xml_2 = ONIX::XMLGenerator.new(product)
    @elibri_xml_versions = Elibri::XmlVersions.new(xml, xml_2)
    @elibri_xml_versions.compare.should eq(true)
  end
end