$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "querify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "querify"
  s.version     = Querify::VERSION
  s.authors     = ["Kenaniah Cerny"]
  s.email       = ["kenaniah@spidrtech.com"]
  s.homepage    = 'http://rubygems.org/gems/activerecord-querify'
  s.summary     = "Query string filters for Active Record queries"
  s.description = "Extends Active Record to accept parameter hashes as query predicates"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.5.1"

  s.add_development_dependency "sqlite3"
end
