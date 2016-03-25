require 'active_support/concern'

# General classes
require 'activerecord/querify/value'

# Pagination module
require 'activerecord/querify/exceptions'
require 'activerecord/querify/paginate'

# Sorting module
require 'activerecord/querify/sort'
require 'activerecord/querify/sortable'

# Filtering module
require 'activerecord/querify/filterable'

# Hash filters module
require 'activerecord/querify/filter'

# Expressions module
require 'activerecord/querify/expression'

# Rails integration
require 'activerecord/querify/middleware'
require 'activerecord/querify/railtie' if defined? ::Rails::Railtie

module ActiveRecord
	module Querify

		extend ActiveSupport::Concern

		class << self

			attr_accessor :params
			attr_accessor :headers
			attr_accessor :columns
			attr_accessor :where_filters, :having_filters
			attr_accessor :sorts

			def config
				@@config ||= Config.new
			end

			def reset_config
				@@config = Config.new
			end

			def configure
				yield self.config
			end

			# Recursively flattens a hash (http://stackoverflow.com/a/12270255)
			def flatten_hash(hash)
				hash.flat_map do |key, value|
					if value.is_a?(Hash)
						flatten_hash(value).map { |ks, v| [[key] + ks, v] }
					else
						[[[key], value]]
					end
				end.to_h
			end

			# Returns a safely quoted version of the column name
			def quote_column name

				# Always treat expressions as quoted
				if name.is_a?(Querify::Expression)
					return name.to_s
				end

				# Check to see if our column is a prefix
				table, col = name.to_s.split ".", 2

				if col.nil?
					field = ActiveRecord::Base.connection.quote_column_name name
				else
					field = ActiveRecord::Base.connection.quote_table_name table
					field += "."
					field += ActiveRecord::Base.connection.quote_column_name col
				end

				field

			end

		end

		class Config
			attr_accessor :per_page
			attr_accessor :min_per_page
			attr_accessor :max_per_page
		end

		# Determines the columns available for a query
		protected def determine_columns columns: {}, only: false

			columns = columns.stringify_keys
			unless only
				columns = _detect_columns.merge columns
			end

			# Ensure the sanity of all column types
			columns.each do |name, type|
				raise Querify::InvalidColumnType, ":#{type} is not a known column type for column '#{name}'" unless Value::TYPES.include? type.to_sym
			end

			# Return it
			columns

		end

		# Detects available columns and returns their types
		private def _detect_columns

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

	# Set up defaults
	Querify.headers ||= {}
	Querify.params ||= {}
	Querify.columns ||= {}

	# Mix into ActiveRecord
	::ActiveRecord::Base.extend Querify
	klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
	klasses.each { |klass| klass.send(:include, Querify)}
end
