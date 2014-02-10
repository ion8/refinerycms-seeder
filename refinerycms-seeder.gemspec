$:.push File.expand_path("../lib", __FILE__)
require "refinery/seeder/version"

Gem::Specification.new do |s|
  s.name = "refinerycms-seeder"
  s.version = Refinery::Seeder::VERSION
  s.authors = ["Mat Allen"]
  s.email = ["mat@ion8.net"]
  s.homepage = "https://github.com/ion8/refinerycms-seeder"
  s.summary = %q{A quick little DSL for seeding RefineryCMS Pages.}
  s.description = %q{
Refinery Seeder provides a DSL for defining Refinery CMS Pages and PageParts
to load when seeding (rake db:seed). The contents of each PagePart are
loaded from templates based on a naming convention, and images are loaded and
can be referenced in the templates using a helper.}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'i18n', "~> 0.6.9"
  s.add_development_dependency 'rspec'

end
