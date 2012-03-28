# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "elibri_xml_versions/version"

Gem::Specification.new do |s|
  s.name        = "elibri_xml_versions"
  s.version     = ElibriXmlVersions::VERSION
  s.authors     = ["Piotr Szmielew"]
  s.email       = ["p.szmielew@beinformed.pl"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "elibri_xml_versions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"
  s.add_development_dependency "builder"
  
  s.add_development_dependency "ruby-debug"
  
  s.add_runtime_dependency "elibri_onix_dict"
  s.add_runtime_dependency 'elibri_api_client'
end
