require "elibri_xml_versions/version"
require 'elibri_api_client'
require 'elibri_onix_dict'


module Elibri
  
  class XmlVersions
    
    attr_accessor :a, :b
    
    def initialize(a, b)
      @a = a
      @b = b
    end
    
    def compare
      return true
    end
    
  end
  
end
