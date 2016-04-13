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

			def flatten_params hash = self.flatten_hash(self.params)
				self.flatten_hash(hash).map do |item|
					item.flatten
				end
			end

			def symbolize val
				return val if val.is_a? Symbol
				val.sub(/^:/, '').to_sym
			end

			# Returns a safely quoted version of the column name
			def quote_column name

				# Always treat expressions as quoted
				if name.is_a?(Querify::Expression)
					return name.to_s
				end

				# Check to see if our column is a prefix
				table, col = name.to_s.reverse.split(".", 2).map(&:reverse).reverse

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

				# Determine the table names
				tables = []
				self.joins_values.each do |table|
					if Arel::Nodes::Node === table
						tables = tables.concat(_resolve_arel_nodes(table))
					else
						tables << table.to_s
					end
				end

				# Convert tables to columns
				tables.uniq.each do |table|

					# Find the model
					model = nil
					ActiveRecord::Base.descendants.each do |m|
						if m.table_name == table
							model = m
							break
						end
					end

					# Add the columns
					model.columns_hash.each do |name, col|
						detected_columns["#{model.table_name}.#{name}"] = col.type
					end

				end
			end

			# Return it
			detected_columns

		end

		# Returns a list of tables from an arel node
		protected def _resolve_arel_nodes node

			tables = []

			# Solve attribute nodes
			if Arel::Attributes::Attribute === node
				tables << node.relation.name
			end

			# Solve table nodes
			if Arel::Table === node
				tables << node.name
			end

			# Solve expression nodes
			if node.respond_to? :expr
				tables = tables.concat(_resolve_arel_nodes(node.expr))
			end

			# Solve left
			if node.respond_to? :left
				tables = tables.concat(_resolve_arel_nodes(node.left))
			end

			# Solve right
			if node.respond_to? :right
				tables = tables.concat(_resolve_arel_nodes(node.right))
			end

			# Return any tables found
			return tables

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
