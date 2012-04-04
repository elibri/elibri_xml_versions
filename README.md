[![Build Status](https://secure.travis-ci.org/elibri/elibri_xml_versions.png?branch=master)](http://travis-ci.org/elibri/elibri_xml_versions)

Gem created for comparing eLibri xml objects.

Currently working and tested only on REE.

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

under changes key, will be array of symbol and/or hashes.
Symbols represents attributes that in product_ver2 are different then in product_ver1. If there is hash in changes key, it represents some changes in object that is in one <-> one relation with product_ver2.

Added and deleted contains array of hashes. Every hash has symbol as a key, that is used to access array of elements where changes occures. As a value it contains array of elements that has been added/deleted from product_ver2, in comparision to product_ver1.