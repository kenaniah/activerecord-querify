module ActiveRecord
	module Querify

		class Value

			attr_accessor :value, :type, :operator

			TYPES = [
				:string,
				:text,
				:integer,
				:float,
				:decimal,
				:date,
				:datetime,
				:time,
				:timestamp, # added for convenience
				:binary,
				:boolean,
				:column # Represents another column in the query
			].freeze

			REPLACEMENTS = {
				true: true,
				false: false,
				nil: nil,
				null: nil,
				blank: '',
				empty: ''
			}.freeze

			def initialize value, type, operator

				self.value = value
				self.type = type
				self.operator = operator

			end

			def value
				parsed_value
			end

			def raw_value
				@value
			end

			def type= type

				# Sanity check
				raise Querify::InvalidColumnType, ":#{type} is not a known column type" unless TYPES.include? type.to_sym
				@type = type.to_sym
			end

			# Returns the proper value, given the operator
			def parsed_value

				val = @value

				# Return a convertable value
				return REPLACEMENTS[val[1..-1].to_sym] if val =~ /^\:/ && REPLACEMENTS.has_key?(val[1..-1].to_sym)

				# Convert to a list from delimited input if a list type
				val = val.split(',') if ['IN', 'NOT IN'].include?(@operator) && !val.is_a?(Array)

				# Return a search string
				return "%#{val}%" if ['LIKE', 'ILIKE'].include? @operator

				# Cast the value based on type
				return case @type
				when :string, :text
					# Return a string
					apply(val, :to_s)
				when :integer
					# Return an integer
					apply(val, :to_i)
				when :decimal, :float
					# Return a float
					apply(val, :to_f)
				when :date, :datetime, :time, :timestamp
					# Parse with chronic
					apply(apply(val, :to_s), Chronic.method(:parse))
				when :binary
					# Return a bit
					val ? 1 : 0
				when :boolean
					# Return a boolean
					val ? true : false
				when :column

					column = val.to_s

					# Perform column security
					unless Querify.columns.include?(column)
						raise Querify::InvalidColumn.new(column), "'#{column}' is not an available column"
					end

					# Prefix simple column names when joins are present
					if defined?(self.joins_values) && !column.include?(".")
						column = self.table_name + "." + column
					end

					# Return it
					ActiveRecord::Base.connection.quote_column_name column

				else
					raise "Values typecast case fell through for type :#{@type}"
				end

			end

			# Applies a method to a value
			protected def apply value, method

				if value.is_a? Array
					if method.is_a? Symbol
						value.map { |v| v.send method}
					else
						value.map { |v| method.call v }
					end
				else
					if method.is_a? Symbol
						value.send method
					else
						method.call value
					end
				end

			end

		end

	end
end
