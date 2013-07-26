#encoding: UTF-8

require "elibri_xml_versions/version"
require 'elibri_api_client'
require 'elibri_onix_dict'
require 'digest/sha2'




module Elibri
  
  class XmlVersions
    

    SKIPPED_ATTRIBS = ["@opts", "@default_namespace", "@instance", "@roxml_references"]
    SKIPPED_2 = ["@id", "@id_before_type_cast"]
                        

    def eid
      return "fcb38e846e666d8d686c491a23431a7b0336451b"
    end
    
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
      @stored_diff ||= check_tree(@a, @b)
      @stored_diff
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
        a.compact!
        b.compact!
        if a.all? { |x| x.respond_to?(:eid) }
          a.sort! { |x,y| x.eid <=> y.eid }
          b.sort! { |x,y| x.eid <=> y.eid }
        end
        if a.all? { |x| x.instance_variables.include? "@id_before_type_cast"} || a.all? { |x| x.instance_variables.include? "@import_id"}
          a_m = a.map { |x| x.eid }
          b_m = b.map { |x| x.eid }
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
          if a.all? { |x| x.respond_to?(:eid) } && b.all? { |x| x.respond_to?(:eid) }
            deleted_ids = a.map(&:eid) - b.map(&:eid)
            added_ids = b.map(&:eid) - a.map(&:eid)
            deleted_ids.each do |eid|
              if a.find { |x| x.eid == eid } && !a.find { |x| x.eid == eid }.blank?
                deleted << a.find { |x| x.eid == eid }
                a.delete(a.find { |x| x.eid == eid })
              end
            end
            added_ids.each do |eid|
              if b.find { |x| x.eid == eid } && !b.find { |x| x.eid == eid }.blank?
                added << b.find { |x| x.eid == eid }
                b.delete(b.find { |x| x.eid == eid })
              end
            end
          else
            deleted_ids = a.map(&:id) - b.map(&:id)
            added_ids = b.map(&:id) - a.map(&:id)
            deleted_ids.each do |id|
              if a.find { |x| x.id == id } && !a.find { |x| x.id == id }.blank?
                deleted << a.find { |x| x.id == id }
                a.delete(a.find { |x| x.id == id })
              end
            end
            added_ids.each do |eid|
              if b.find { |x| x.id == id } && !b.find { |x| x.id == id }.blank?
                added << b.find { |x| x.id == id }
                b.delete(b.find { |x| x.id == id })
              end
            end
          end        
        end
        #obsługa różnych elementów w arrayu
        a.each_with_index do |element, i|
          ret = check_tree(element, b[i])
          [:changes, :added, :deleted].each do |key|
            ret[key] = ret[key].map { |x| {element.eid => x}}
          end
          changes += ret[:changes]
          added += ret[:added]
          deleted += ret[:deleted]
        end
      else
        vars = []
        if a.class.to_s.include? "Elibri::ONIX"
          vars += a.class::ATTRIBUTES
          vars += a.class::RELATIONS
        end
        vars = a.instance_variables if vars.blank?
        vars.each do |attrib|
          next if SKIPPED_ATTRIBS.include? attrib
          attrib = attrib.to_s.gsub("@", "").to_sym if attrib.is_a?(String)
          if a.send(attrib).is_a? Array
            if is_all_simple?(a.send(attrib))
              changes << attrib if a.send(attrib) != b.send(attrib)
            else
              ret = check_tree(a.send(attrib), b.send(attrib))
              #TODO: otestować to
              changes << {attrib => ret[:changes]} if !ret[:changes].blank?
              added << {attrib => ret[:added]} if !ret[:added].blank?
              deleted << {attrib => ret[:deleted]} if !ret[:deleted].blank?
            end
          else
            if (is_simple_type?(a.send(attrib)) || b.send(attrib).is_a?(NilClass) || 
                b.send(attrib).is_a?(TrueClass) || b.send(attrib).is_a?(FalseClass) )
              changes << attrib if a.send(attrib) != b.send(attrib)
            else
              #klasa zlozona
              ret = check_tree(a.send(attrib), b.send(attrib))
              changes << {attrib => ret[:changes]} if !ret[:changes].blank?
              added << {attrib => ret[:added]} if !ret[:added].blank?
              deleted << {attrib => ret[:deleted]} if !ret[:deleted].blank?
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
        vars = []
        if object.class.to_s.include? "Elibri::ONIX"
          vars += object.class::ATTRIBUTES
          vars += object.class::RELATIONS
        end
        vars = object.instance_variables if vars.blank?
        vars.each do |attrib|
          next if SKIPPED_ATTRIBS.include? attrib
          next if SKIPPED_2.include? attrib
          attrib = attrib.to_s.gsub("@", "").to_sym if attrib.is_a?(String)
          if object.send(attrib).is_a? Array
            result << calculate_hash(object.send(attrib))
          elsif is_simple_type?(object.send(attrib))
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
    
    def is_simple_type?(obj)
      obj.is_a?(String) || obj.is_a?(Numeric) || 
      obj.is_a?(NilClass) || obj.is_a?(TrueClass) || 
      obj.is_a?(FalseClass) || obj.is_a?(Date) || 
      obj.is_a?(Symbol) || obj.is_a?(Fixnum)
    end
    
    def is_all_simple?(arr)
      arr.all? {|e| is_simple_type?(e) }
    end
    
  end
  
end
