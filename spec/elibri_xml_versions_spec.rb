require 'spec_helper'

describe Elibri::XmlVersions do
  
  it "should return true for same elibri objects" do
    generated_product = onix_from_mock(:basic_product)
    generated_product_2 = onix_from_mock(:basic_product)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq([])
  end
  
  it "should return false for different elibri objects" do
    generated_product = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a97')
    generated_product_2 = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a95')
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq([:record_reference])
  end
  
end