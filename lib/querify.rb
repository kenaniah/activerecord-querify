require 'active_support/concern'

#require 'querify/condition'
require 'querify/paginate'
require 'querify/sortable'
require 'querify/middleware'
require 'querify/railtie' if defined? ::Rails::Railtie

module Querify

	extend ActiveSupport::Concern

	class << self

		attr_accessor :params
		attr_accessor :headers

		def config
			@@config ||= Config.new
		end

		def configure
			yield self.config
		end

	end

	class Config
		attr_accessor :per_page
		attr_accessor :min_per_page
		attr_accessor :max_per_page
	end

	def querify options = {}
		self
	end

end
Querify.headers ||= {}
Querify.params ||= {}

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
