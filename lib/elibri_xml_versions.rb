#encoding: UTF-8

require "elibri_xml_versions/version"
require 'elibri_api_client'
require 'elibri_onix_dict'
require 'digest/sha2'




module Elibri
  
  class XmlVersions
    

    SKIPPED_ATTRIBS = ["@opts", "@default_namespace", "@instance", "@roxml_references"]
    SKIPPED_2 = ["@id", "@id_before_type_cast"]
                        

    
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
     if a.class != b.class
       raise "Different classes for diff" 
     end
=begin
        if a.class.is_a? NilClass
          return {:deleted => [], :added => [], :changes => [b]}
        elsif b.class.is_a? NilClass
          return {:deleted => [], :added => [], :changes => [a]}
        else

        end
      end
=end
      changes = []
      deleted = []
      added = []
      if a.is_a? Array
        a.sort! { |x,y| x.id <=> y.id }
        b.sort! { |x,y| x.id <=> y.id }
        if a.all? { |x| x.instance_variables.include? "@id_before_type_cast"} || a.all? { |x| x.instance_variables.include? "@import_id"}
          a_m = a.map { |x| x.id }
          b_m = b.map { |x| x.id }
        else
=begin
        ch = []
        del = []
        add = []
        a.each_with_index do |element, i|
          res = check_tree(element, b[i])
          ch += res[:changes]
          del += res[:deleted]
          add += res[:added]
        end
=end       
        #obsługa dodania i usunięcia elementów
        #problematyczne są części rekordu które nie są identyfikowalne jako identyczne :(
          a_m = a.map { |x| calculate_hash(x) }
          b_m = b.map { |x| calculate_hash(x) }
        end
     #   if a.map(&:id) != b.map(&:id)
        if a_m != b_m
          deleted_ids = a.map(&:id) - b.map(&:id)
          added_ids = b.map(&:id) - a.map(&:id)
          deleted_ids.each do |id|
            if a.find { |x| x.id == id } && !a.find { |x| x.id == id }.blank?
              deleted << a.find { |x| x.id == id }
              a.delete(a.find { |x| x.id == id })
            end
          end
          added_ids.each do |id|
            if b.find { |x| x.id == id } && !b.find { |x| x.id == id }.blank?
              added << b.find { |x| x.id == id }
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
          attrib = attrib.to_s.gsub("@", "").to_sym
          if a.send(attrib).is_a? Array
            ret = check_tree(a.send(attrib), b.send(attrib))
            changes << {attrib, ret[:changes]} if !ret[:changes].blank?
            added << {attrib, ret[:added]} if !ret[:added].blank?
            deleted << {attrib, ret[:deleted]} if !ret[:deleted].blank?
          else
            if (a.send(attrib).is_a?(String) || a.send(attrib).is_a?(Numeric) || a.send(attrib).is_a?(NilClass) || b.send(attrib).is_a?(NilClass))
              changes << attrib if a.send(attrib) != b.send(attrib)
            else
              #klasa zlozona
              ret = check_tree(a.send(attrib), b.send(attrib))
              changes << {attrib, ret[:changes]} if !ret[:changes].blank?
              added << {attrib, ret[:added]} if !ret[:added].blank?
              deleted << {attrib, ret[:deleted]} if !ret[:deleted].blank?
            end
          end
        end
      end
      return {:deleted => deleted, :added => added, :changes => changes}
    end
    
    def calculate_hash(object)
      result = []
      if object.is_a? Array
        object.each { |x| result << calculate_hash(x) }
      else
        object.instance_variables.each do |attrib|
          next if SKIPPED_ATTRIBS.include? attrib
          next if SKIPPED_2.include? attrib
          attrib = attrib.to_s.gsub("@", "").to_sym
          if object.send(attrib).is_a? Array
            result << calculate_hash(object.send(attrib))
          elsif object.send(attrib).is_a?(String) || object.send(attrib).is_a?(Numeric) || object.send(attrib).is_a?(Fixnum) || object.send(attrib).is_a?(Symbol)
            result << object.send(attrib)
          else
            result << calculate_hash(object.send(attrib))
          end
        end
      end
      return Digest::SHA1.hexdigest(result.join("-"))
    end
    
    def convert_arr_to_hash(arr)
      {}.tap do |hash|
        arr.each do |pair|
          hash[pair.keys.first] = pair.values.first
        end
      end
    end
    
  end
  
end
