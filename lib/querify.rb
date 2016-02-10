require 'active_support/concern'

# Pagination module
require 'querify/exceptions'
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
	def querify! allowed_columns: [], options: {}
		_querify true, allowed_columns: allowed_columns, options: options
	end

	# Filters the query using :where from the params hash, silently ignoring InvalidOperator exceptions
	def querify allowed_columns: [], options: {}
		_querify false, allowed_columns: allowed_columns, options: options
	end

	protected def _querify throw_errors, allowed_columns: [], options: {}

		query = self

		# Prepare the list of allowed columns (if passed)
		allowed_columns = allowed_columns.map &:to_s

		# Filter the query based on :where from query string
		if Querify.params[:where]

			Querify.params[:where].each do |column, filters|

				filters.each do |operator, value|

					begin

						column = column.to_s

						# Perform column security
						unless allowed_columns.empty? || allowed_columns.include?(column)
							raise Querify::InvalidFilterColumn, "'#{column}' is not a filterable column"
						end

						# Filter the query
						predicate = Querify::Predicate.new column, operator, value
						query = query.where(*predicate.to_a)

					rescue Querify::Error => err
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
