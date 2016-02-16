require 'active_support/concern'

# General classes
require 'querify/value'

# Pagination module
require 'querify/exceptions'
require 'querify/paginate'

# Sorting module
require 'querify/sort'
require 'querify/sortable'

# Filtering module
require 'querify/filterable'

# Hash filters module
require 'querify/filter'

# Rails integration
require 'querify/middleware'
require 'querify/railtie' if defined? ::Rails::Railtie

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
Querify.headers ||= {}
Querify.params ||= {}
Querify.columns ||= {}

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
