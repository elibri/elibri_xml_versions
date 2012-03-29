require 'spec_helper'

describe Elibri::XmlVersions do
  
  it "should return true for same basic elibri objects" do
    generated_product = onix_from_mock(:basic_product)
    generated_product_2 = onix_from_mock(:basic_product)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})
  end
  
  it "should return false for different basic elibri objects" do
    generated_product = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a97')
    generated_product_2 = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a95')
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => [:record_reference]})
  end
  
  it "should return true for same book elibri objects" do
    generated_product = onix_from_mock(:book_example)
    generated_product_2 = onix_from_mock(:book_example)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq([])
  end
  
end