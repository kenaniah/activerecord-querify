require 'active_support/concern'

# Pagination module
require 'querify/paginate'

# Sorting module
require 'querify/sort'
require 'querify/sortable'

# Hash predicates module
require 'querify/predicate'

# Rails integration
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

		def reset_config
			@@config = Config.new
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

	# Filters the query using :where from the params hash, throwing InvalidOperator exceptions
	def querify!
		querify true
	end

	# Filters the query using :where from the params hash, silently ignoring InvalidOperator exceptions
	def querify throw_errors = false

		query = self

		# Filter the query based on :where from query string
		if Querify.params[:where]

			Querify.params[:where].each do |column, filters|
				filters.each do |operator, value|
					begin
						predicate = Querify::Predicate.new column, operator, value
						query = query.where(*predicate.to_a)
					rescue Querify::InvalidOperator => err
						raise err if throw_errors
					end
				end
			end

		end

		# Return the (potentially) filtered query
		return query

	end

end
Querify.headers ||= {}
Querify.params ||= {}

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
