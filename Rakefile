require "bundler/gem_tasks"

desc "Running specs"
task :spec do |t|
  exec "cd spec/ && bundle exec rspec elibri_xml_versions_spec.rb"
end

task :default => ["spec"]