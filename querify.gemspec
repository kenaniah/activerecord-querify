$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "activerecord/querify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord-querify"
  s.version     = ActiveRecord::Querify::VERSION
  s.authors     = ["Kenaniah Cerny"]
  s.email       = ["kenaniah@gmail.com"]
  s.homepage    = 'http://rubygems.org/gems/activerecord-querify'
  s.summary     = "Query string filters for Active Record queries"
  s.description = "Querify provides an easy interface for manipulating Active Record queries given a hash of parameters. It extends Active Record classes to provide pagination, sorting, and filtering."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "chronic", "~> 0.10"

  s.add_development_dependency "sqlite3", ">= 1.3"
end
