[![Build Status](https://secure.travis-ci.org/elibri/elibri_xml_versions.png?branch=master)](http://travis-ci.org/elibri/elibri_xml_versions)

Gem created for comparing eLibri xml objects.

Currently working and tested on 1.8 version of Ruby (REE, jRuby 1.8, Ruby 1.8.7).

Basic usage:
``Elibri::XmlVersions.new(product_ver1, product_ver2).diff``

`product_ver1` and `product_ver2` must be same classes

It will return hash:
```ruby
{
  :added => [],
  :changes => [], 
  :deleted => []
  }
```

In case of comparising Elibri products:

* added and deleted may contain only: contributors, related_products, languages, measures, supply_details, measures, title_details, collections, extents, subjects, audience_ranges, text_contents, supporting_resources, sales_restrictions, authors, ghostwriters, scenarists, originators, illustrators, photographers, author_of_prefaces, drawers, cover_designers, inked_or_colored_bys, editors, revisors, translators, editor_in_chiefs, read_bys

* changes may contain all previous mentioned elements as a keys for embedded hashes (meaning changes in embedded elements) and also may contain additional attributes: elibri_dialect, height, width, thickness, weight, ean, isbn13, number_of_pages, duration, file_size, publisher_name, publisher_id, imprint_name, current_state, reading_age_from, reading_age_to, table_of_contents, description, reviews, excerpts, series, title, subtitle, collection_title, collection_part, full_title, original_title, trade_title, parsed_publishing_date, record_reference, deletion_text, cover_type, cover_price, vat, pkwiu, product_composition, product_form, imprint, publisher, product_form, no_contributor, edition_statement, number_of_illustrations, publishing_status, publishing_date, premiere, front_cover, series_names, elibri_product_category1_id, elibri_product_category2_id, preview_exists, short_description

* If attribute appear as a symbol in changes array, that it means it has been changed between compared products.

* If hash appears in changes, that means that key of that hash is a embedded relation that has been changed, and in values you will find array containing hashes. In that most inner hashes, key means Elibri internal id of element changed and value is symbol for attribute changed.

* In added and deleted arrays you will find objects that needed to be removed or added to your local copy of Elibri object.

under changes key, will be array of symbol and/or hashes.
If there is change deeper in structure it will be represented like this:
`:changes => [{:contributors => [{2167055520 => :key_names}]`
Symbols represents attributes that in product_ver2 are different then in product_ver1. If there is hash in changes key, it represents some changes in object that is in one <-> one relation with product_ver2.

Added and deleted contains array of hashes. Every hash has symbol as a key, that is used to access array of elements where changes occures. As a value it contains array of elements that has been added/deleted from product_ver2, in comparision to product_ver1.

Example of result, when comparing two elibri products, when full_title changed and in contributors name of one changes. Also it adds a new language and delete one text_content.
```ruby
{
  :added => [<Elibri::ONIX::Release_3_0::Language>],
  :changes => [:full_title, {:contributors => [ {123456 => :name} ] } ],
  :deleted => [<Elibri::ONIX::Release_3_0::TextContent>]
}