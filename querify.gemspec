$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "querify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "querify"
  s.version     = Querify::VERSION
  s.date        = '2016-02-06'
  s.authors     = ["Kenaniah Cerny"]
  s.email       = ["kenaniah@spidrtech.com"]
  s.homepage    = 'http://rubygems.org/gems/querify'
  s.summary     = "Query string filters for Active Record queries"
  s.description = "Extends Active Record to accept parameter hashes as query predicates"
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "chronic"
  s.add_dependency "factory_girl_rails"

  s.add_development_dependency "sqlite3"
end
