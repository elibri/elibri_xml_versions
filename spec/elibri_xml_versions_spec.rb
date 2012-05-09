require 'spec_helper'
$VERBOSE = nil #temp: supress id warnings
describe Elibri::XmlVersions do

  RAW_EXTRAS = {
    :imprint => nil,
    :authorship_kind => nil,
    :contributors => [],
    :languages => [],
    :other_texts => [],
    :series_membership_kind => nil,
    :series_memberships => [],
    :facsimiles => [],
    :similar_products => [],
    :product_attachments => [],
    :product_availabilities => []
  }
  it "should return no changes for same basic elibri object" do
    generated_product = onix_from_mock(:basic_product)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})
  end

  it "should return no changes for same basic elibri object double generated" do
    generated_product = onix_from_mock(:basic_product)
    generated_product_2 = onix_from_mock(:basic_product)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})
  end
 
  it "should return change for different basic elibri objects" do
    generated_product = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a97')
    generated_product_2 = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a95')
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => [:record_reference]})
  end
  
  it "should return change in author on same basic elibri objects" do
    author = Elibri::XmlMocks::Examples.contributor_mock(:id => 2167055520)
    author_2 = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Waza', :id => 2167055520)
    generated_product = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a97', :contributors => [author])
    generated_product_2 = onix_from_mock(:basic_product, :record_reference => 'fdb8fa072be774d97a97', :contributors => [author_2])
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    diff = @elibri_xml_versions.diff
    diff[:deleted].should eq([])
    diff[:added].should eq([])
    diff[:changes].should eq( [ {:contributors => [{2167055520 => :key_names}] }  ] )
  end

  it "should return no changes for same book elibri objects" do
    generated_product = onix_from_mock(:book_example)
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})    
  end

  it "should return no changes for same book elibri objects double generated" do
    mock = Elibri::XmlMocks::Examples.review_mock
    generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [mock]) )
    generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [mock]) )
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    result = @elibri_xml_versions.diff
    (@elibri_xml_versions.convert_arr_to_hash result[:changes]).count.should eq(0) 
  end

  it "should return change for different book elibri objects" do
    review_mock = Elibri::XmlMocks::Examples.review_mock
    supply_details = Elibri::XmlMocks::Examples.supply_detail_mock
    generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [review_mock], :product_availabilities => [supply_details], :record_reference => 'fdb8fa072be774d97a97'))
    generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [review_mock], :product_availabilities => [supply_details], :record_reference => 'fdb8fa072be774d97a95'))
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => [:record_reference]})
  end

  it "should return added element when new review is added" do
    generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [Elibri::XmlMocks::Examples.review_mock]))
    generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(:other_texts => [Elibri::XmlMocks::Examples.review_mock, Elibri::XmlMocks::Examples.review_mock(:text_author => "lobuz lobuzialski")]))
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    result = @elibri_xml_versions.diff
    (@elibri_xml_versions.convert_arr_to_hash result[:added])[:reviews].count.should eq(2)
    (@elibri_xml_versions.convert_arr_to_hash result[:deleted])[:reviews].count.should eq(1)
    (@elibri_xml_versions.convert_arr_to_hash result[:added])[:text_contents].count.should eq(2)
    (@elibri_xml_versions.convert_arr_to_hash result[:deleted])[:text_contents].count.should eq(1)
    end

    it "should return no changes for same onix_record_identifiers_example objects" do
      generated_product = onix_from_mock(:onix_record_identifiers_example)
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product.products.first)
      @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})    
    end
  
    it "should return no changes for double generated onix_record_identifiers_example objects" do
      generated_product = onix_from_mock(:onix_record_identifiers_example)
      generated_product_2 = onix_from_mock(:onix_record_identifiers_example)      
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})    
    end
    SPLITTING_SYMBOLS = [
      :publisher_name
    ]
  
    SIMPLE_SYMBOLS = [
      :publisher_name, :record_reference
    ]

    TRAVERSE_VECTOR = {
      :or_title => :original_title,
      :publisher_name => :publisher_name,
      :record_reference => :record_reference,
      :deletion_text => :deletion_text,
      :isbn_value => :isbn13,
      :ean => :ean,
      :deletion_text => :deletion_text,
      :trade_title => :trade_title,
      :pkwiu => :pkwiu,
      :title => :title,
      :subtitle => :subtitle,
      :edition_statement => :edition_statement,
      :audience_age_from => :reading_age_from,
      :audience_age_to => :reading_age_to,
      :price_amount => :cover_price,
      :vat => :vat,
      :preview_exists? => :preview_exists,
      :elibri_product_category1_id => :elibri_product_category1_id,
      :elibri_product_category2_id => :elibri_product_category2_id
    }

    it "should find the difference in categories" do
      generated_product = onix_from_mock(:onix_subjects_example)
      generated_product_2 = onix_from_mock(:onix_subjects_example)
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff.should eq({:deleted => [], :added => [], :changes => []})

      generated_product = onix_from_mock(:onix_subjects_example, :elibri_product_category1_id => 440, :elibri_product_category2_id => nil)
      generated_product_2 = onix_from_mock(:onix_subjects_example, :elibri_product_category1_id => 550, :elibri_product_category2_id => nil)
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff[:changes].should include(:elibri_product_category1_id)

      generated_product = onix_from_mock(:onix_subjects_example, :elibri_product_category1_id => 440, :elibri_product_category2_id => 441)
      generated_product_2 = onix_from_mock(:onix_subjects_example, :elibri_product_category1_id => 550, :elibri_product_category2_id => 551)
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff[:changes].should include(:elibri_product_category1_id, :elibri_product_category2_id)
    end

    #strings
    [
      :publisher_name, :record_reference,
      :ean, :isbn_value, :deletion_text, :or_title,
      :trade_title, :pkwiu, :title, :subtitle, 
      :edition_statement
    ].each do |symbol|
    
      it "should return change when #{symbol} change in two books objects (one with default settings)" do
        string = "ehdroruwnm"
        generated_product = onix_from_mock(:book_example, RAW_EXTRAS)
        generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string) )
        @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
        @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
      end
 
      it "should return change when #{symbol} change in two books objects" do
        string = "ehdroruwnm"
        string2 = "TOXYAUEJ"
        review_mock = Elibri::XmlMocks::Examples.review_mock
        supply_details = Elibri::XmlMocks::Examples.supply_detail_mock
        generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string))
        generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string2))
        @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
        @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
      end
    
      it "should return change when #{symbol} change in two basic products objects (one with default settings)" do
        string = "ehdroruwnm"
        generated_product = onix_from_mock(:basic_product)
        generated_product_2 = onix_from_mock(:basic_product, {symbol => string})
        @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
        if SPLITTING_SYMBOLS.include?(symbol)
          @elibri_xml_versions.diff[:changes].should include(symbol.to_s.split("_")[0].to_sym)
        else
          @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
        end
      end
    
      it "should return change when #{symbol} change in two basic products objects" do
        string = "ehdroruwnm"
        string2 = "TOXYAUEJ"
        generated_product = onix_from_mock(:basic_product, {symbol => string})
        generated_product_2 = onix_from_mock(:basic_product, {symbol => string2})
        @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
        @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
      end

    #end strings  
    end

  #bools
  [
    :preview_exists?
  ].each do |symbol|
      
     it "should see the change in #{symbol} attribute" do
        generated_product = onix_from_mock(:basic_product, symbol => true)
        generated_product_2 = onix_from_mock(:basic_product, symbol => false)
        @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
        @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
     end
  
    #end bools 
    end


  #integers
  [
    :audience_age_from, :audience_age_to, :price_amount, :vat
  ].each do |symbol|
    
    it "should return change when #{symbol} change in two books objects (one with default settings)" do
      string = 52
      generated_product = onix_from_mock(:book_example, RAW_EXTRAS)
      generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string))
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
    end

    it "should return change when #{symbol} change in two books objects" do
      string = 52
      string2 = 44
      review_mock = Elibri::XmlMocks::Examples.review_mock
      supply_details = Elibri::XmlMocks::Examples.supply_detail_mock
      generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string))
      generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge(symbol => string2))
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
    end
  
    it "should return change when #{symbol} change in two basic products objects (one with default settings)" do
      string = 52
      generated_product = onix_from_mock(:basic_product)
      generated_product_2 = onix_from_mock(:basic_product, {symbol => string})
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      if SPLITTING_SYMBOLS.include?(symbol)
        @elibri_xml_versions.diff[:changes].should include(symbol.to_s.split("_")[0].to_sym)
      else
        @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
      end
    end
  
    it "should return change when #{symbol} change in two basic products objects" do
      string = 52
      string2 = 44
      generated_product = onix_from_mock(:basic_product, {symbol => string})
      generated_product_2 = onix_from_mock(:basic_product, {symbol => string2})
      @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
      @elibri_xml_versions.diff[:changes].should include(TRAVERSE_VECTOR[symbol])
    end
    
  #end of integers  
  end  

  it "should detect change in object inside basic product" do
    imprint = Elibri::XmlMocks::Examples.imprint_mock
    imprint_2 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'second')
    generated_product = onix_from_mock(:basic_product, {:imprint => imprint})
    generated_product_2 = onix_from_mock(:basic_product, {:imprint => imprint_2})
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff[:changes].should include({:imprint => [:name]})
  end

  it "should detect change in object inside book product" do
    imprint = Elibri::XmlMocks::Examples.imprint_mock
    imprint_2 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'second')
    generated_product = onix_from_mock(:book_example, RAW_EXTRAS.merge({:imprint => imprint}))
    generated_product_2 = onix_from_mock(:book_example, RAW_EXTRAS.merge({:imprint => imprint_2}))
    @elibri_xml_versions = Elibri::XmlVersions.new(generated_product.products.first, generated_product_2.products.first)
    @elibri_xml_versions.diff[:changes].should include({:imprint => [:name]})
  end
end
