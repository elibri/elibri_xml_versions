module MockMethodMissing
  #TODO: dodać sprawdzanie czy obiekt przypadkiem nie zna metody
  def method_missing(m, *args, &block)
    if m == :product_form_onix_code
      super
    elsif Attributes::EXCLUDED_ATTRIBUTES[product_form_onix_code].include? m
     nil
    elsif [:kind_of_audio?, :kind_of_book?, :kind_of_map?, :kind_of_ebook?, :kind_of_measurable?].include? m
      nil #TODO - dlaczego tak jest, jak to poprawić
    elsif [:series_membership_kind, :authorship_kind, :collection, :subtitle].include? m #nieobowiązkowe pola
      nil
    elsif [:series_memberships, :product_availabilities].include? m #nieobowiązkowe relacje
      []
    else
      super
    end
  end 
end

module Attributes
  DIMENSION_ATTRIBUTES = [ :width, :height, :thickness, :weight ]
  EPUB_ATTRIBUTES = [ :file_size, :epub_technical_protection_onix_code, :product_form_detail_onix_code, :epub_sale_restricted_to, :epub_sale_not_restricted ]
  BOOK_ATTRIBUTES = [ :number_of_pages, :number_of_illustrations, :excerpt, :edition_statement ]

  # Lista pól, które nie mają sensu dla określonych typów produktów.
  EXCLUDED_ATTRIBUTES = {
    # książka
    "BA" => [:duration, :map_scale, EPUB_ATTRIBUTES].flatten,
    # e-book
    "EA" => [:duration, :paper_type_id, :stock_quantity, :stock_operator, :print_run, :pack_quantity, :map_scale, :cover_type_id, DIMENSION_ATTRIBUTES].flatten,
    # kalendarz
    "PC" => [:duration, :map_scale, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # audio DVD
    "AI" => [:map_scale, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # audio CD
    "AC" => [:map_scale, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # kaseta magnetofonowa
    "AB" => [:map_scale, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # audio MP3
    "AJ" => [:map_scale, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # inny format kartograficzny
    "CZ" => [:duration, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # mapa w rolce
    "CD" => [:duration, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # mapa płaska
    "CC" => [:duration, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # mapa składana
    "CB" => [:duration, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
    # mapa
    "CA" => [:duration, :cover_type_id, BOOK_ATTRIBUTES, EPUB_ATTRIBUTES].flatten,
  }

end