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

	# Filters the query using :where from the params hash, throwing exceptions
	def querify! allowed_columns: {}
		_querify true, allowed_columns: allowed_columns
	end

	# Filters the query using :where from the params hash, silently ignoring exceptions
	def querify allowed_columns: {}
		_querify false, allowed_columns: allowed_columns
	end

	protected def _querify throw_errors, allowed_columns: {}, autodetect_columns: true

		query = self

		# Prepare the list of allowed columns
		allowed_columns = allowed_columns.stringify_keys
		if autodetect_columns
			allowed_columns = _detect_columns.merge allowed_columns
		end

		# Filter the query based on :where from query string
		if Querify.params[:where]

			Querify.params[:where].each do |column, filters|

				filters.each do |operator, value|

					begin

						column = column.to_s

						# Perform column security
						unless allowed_columns.include?(column)
							raise Querify::InvalidFilterColumn, "'#{column}' is not a filterable column"
						end

						# Prefix simple column names when joins are present
						if defined?(self.joins_values) && !column.include?(".")
							column = self.table_name + "." + column
						end

						# Filter the query
						predicate = Querify::Predicate.new column, operator, value, allowed_columns[column]
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

	# Detects available columns and returns their types
	protected def _detect_columns

		# Detect columns available from the model
		detected_columns = {}
		self.columns_hash.each do |name, col|
			detected_columns[name] = col.type
			detected_columns["#{self.table_name}.#{name}"] = col.type
		end

		# Detect columns available via joins
		if defined? self.joins_values
			self.joins_values.each do |table|
				model = table.to_s.classify.constantize
				model.columns_hash.each do |name, col|
					detected_columns["#{model.table_name}.#{name}"] = col.type
				end
			end
		end

		# Return it
		detected_columns

	end

end
Querify.headers ||= {}
Querify.params ||= {}

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
