[![Build Status](https://secure.travis-ci.org/elibri/elibri_xml_versions.png?branch=master)](http://travis-ci.org/elibri/elibri_xml_versions)

Gem created for comparing eLibri xml objects.
More info coming soon.
Currently working and tested only on REE.

Basic usage:
``Elibri::XmlVersions.new(product_ver1, product_ver2).diff``

it will return hash:
{:added => [], :changes => [], :deleted => []}