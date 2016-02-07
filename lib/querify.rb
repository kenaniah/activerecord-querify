require 'active_support/concern'

#require 'querify/condition'
require 'querify/paginate'
require 'querify/railtie' if defined? ::Rails::Railtie

module Querify

	extend ActiveSupport::Concern

	class Config
		attr_accessor :per_page
		attr_accessor :min_per_page
		attr_accessor :max_per_page
	end

	def self.config
		@@config ||= Config.new
	end

	def self.configure
		yield self.config
	end

	def querify options = {}
		self
	end

end

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
