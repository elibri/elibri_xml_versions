require "elibri_xml_versions/version"
require 'elibri_api_client'
require 'elibri_onix_dict'




module Elibri
  
  class XmlVersions
    
    #TODO: wyciagnac do innego pliku
    ATTRIBS = [:elibri_dialect, :height, :width, :thickness, :weight, :ean, :isbn13, :number_of_pages, :duration, 
                        :file_size, :publisher_name, :publisher_id, :imprint_name, :current_state, :reading_age_from, :reading_age_to, 
                        :table_of_contents, :description, :reviews, :excerpts, :series, :title, :subtitle, :collection_title,
                        :collection_part, :full_title, :original_title, :trade_title, :parsed_publishing_date, 
                        #specific for RELEASE 3_0
                        :cover_type, :cover_price, :vat, :pkwiu,
                        :record_reference, :notification_type, :deletion_text,
                        
                        ]
    
    attr_accessor :a, :b
    
    def initialize(a, b)
      @a = a
      @b = b
    end
    
    def diff
      diffs = []
      ATTRIBS.each do |attrib|
        diffs << attrib if @a.send(attrib) != @b.send(attrib)
      end
      diffs
    end
    
  end
  
end
