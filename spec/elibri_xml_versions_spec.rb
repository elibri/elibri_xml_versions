require 'spec_helper'

describe Elibri::XmlVersions do
  
  it "should return true for same elibri objects" do
    @elibri_xml_versions = Elibri::XmlVersions.new(nil, nil)
    @elibri_xml_versions.compare.should eq(true)
  end
end