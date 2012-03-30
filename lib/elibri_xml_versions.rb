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
                        
    TREE_ATTRIBS = [:reviews, :identifiers, :roxml_references, :title_details]
#      :reviews => [:artificial_id, :type_onix_code, :text, :text_author, :updated_at,
#                                           :exportable?, :is_a_review?, :resource_link]
#                    }

    SKIPPED_ATTRIBS = ["@opts", "@default_namespace", "@instance", "@roxml_references"]
                        
    COVER_TYPES= [      1  => 'gąbka',
                        2 => 'kartonowa',
                        3 => 'kartonowa foliowana',
                        4 => 'miękka',
                        5 => 'miękka ze skrzydełkami',
                        6 => 'plastikowa',
                        7 => 'skórzana',
                        8 => 'twarda',
                        9 => 'twarda z obwolutą',
                        10 => 'twarda lakierowana']
                        
    HARDBACK = 8
    PLASTIC = 6
    PAPERBACK = 4
    
    attr_accessor :a, :b
    
    def initialize(a, b)
      @a = a
      @b = b
    end
    
    def diff
=begin
      diffs = []
      @a.instance_variables.each do |attrib|
        attrib = attrib.gsub("@", "").to_sym
        if TREE_ATTRIBS.include? attrib
          tree_attr = @a.send(attrib).map(&:id).sort
          tree_attr_2 = @b.send(attrib).map(&:id).sort
          if tree_attr != tree_attr_2         
            #coś dopisane/usunięte
          else
            #trzeba sprawdzić czy wszystkie są takie same
            attr_1 = @a.send(attrib).sort { |x,y| x.id <=> y.id }
            attr_2 = @b.send(attrib).sort! { |x,y| x.id <=> y.id }
            attr_1.each_with_index do |element, i|
              element.instance_variables.each do |var|
                var = var.gsub("@", "").to_sym
                diffs << [attrib, var] if element.send(var) != attr_2[i].send(var)
              end
            end
          end
        else
          diffs << attrib if @a.send(attrib) != @b.send(attrib)
        end
      end
      diffs
=end
      check_tree(@a, @b)
    end
    
    
    def check_tree(a, b)
      raise "Different classes for diff" if a.class != b.class
      changes = []
      deleted = []
      added = []
      if a.is_a? Array
        a.sort! { |x,y| x.id <=> y.id }
        b.sort! { |x,y| x.id <=> y.id }
        #obsługa dodania i usunięcia elementów
        #problematyczne są części rekordu które nie są identyfikowalne jako identyczne :(
        if a.map(&:id) != b.map(&:id)
          deleted_ids = a.map(&:id) - b.map(&:id)
          added_ids = b.map(&:id) - a.map(&:id)
          deleted_ids.each do |id|
            if a.find { |x| x.id == id } && !a.find { |x| x.id == id }.blank?
              deleted << id
              a.delete(a.find { |x| x.id == id })
            end
          end
          added_ids.each do |id|
            if b.find { |x| x.id == id } && !b.find { |x| x.id == id }.blank?
              added << id
              b.delete(b.find { |x| x.id == id })
            end
          end
        end
        #obsługa różnych elementów w arrayu
        a.each_with_index do |element, i|
          ret = check_tree(element, b[i])
          changes += ret[:changes]
          added += ret[:added]
          deleted += ret[:deleted]
        end
      else
        a.instance_variables.each do |attrib|
          next if SKIPPED_ATTRIBS.include? attrib
          attrib = attrib.gsub("@", "").to_sym
          if a.send(attrib).is_a? Array
            ret = check_tree(a.send(attrib), b.send(attrib))
            changes += [attrib, ret[:changes]] if !ret[:changes].blank?
            added += [attrib, ret[:added]] if !ret[:added].blank?
            deleted += [attrib, ret[:deleted]] if !ret[:deleted].blank?
          else
            if (a.send(attrib).is_a?(String) || a.send(attrib).is_a?(Integer))
              changes << attrib if a.send(attrib) != b.send(attrib)
            else
              #klasa zlozona
              ret = check_tree(a.send(attrib), b.send(attrib))
              changes += [attrib, ret[:changes]] if !ret[:changes].blank?
              added += [attrib, ret[:added]] if !ret[:added].blank?
              deleted += [attrib, ret[:deleted]] if !ret[:deleted].blank?
            end
          end
        end
      end
      return {:deleted => deleted, :added => added, :changes => changes}
    end
    
  end
  
end
