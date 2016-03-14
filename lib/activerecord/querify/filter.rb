require 'chronic'

module ActiveRecord
	module Querify

		# Represents an individual filter to be added to a where clause
		class Filter

			OPERATORS = {
				lt: '<',
				gt: '>',
				gteq: '>=',
				lteq: '<=',
				eq: '=',
				neq: '!=',
				is: 'IS',
				isnot: 'IS NOT',
				like: 'LIKE',
				ilike: 'ILIKE',
				in: 'IN',
				notin: 'NOT IN'
			}.freeze

			INVERTED_OPERATORS = OPERATORS.dup.invert.freeze

			def initialize column, operator, value, type

				self.column = column
				self.operator = operator
				@value = Querify::Value.new value, type, self.operator

			end

			def operator= op

				if OPERATORS.values.include? op.to_s
					@operator = op.to_s
				else
					@operator = OPERATORS[op.to_sym]
				end

				raise(InvalidOperator, "'#{op}' is not a valid operator") unless @operator

				# Notify the value of a changed operator
				@value.operator = @operator if @value

				# Return it
				@operator

			end

			def operator
				@operator
			end

			def column= col
				@column = col.to_s
			end

			def column
				@column
			end

			# Returns a safely quoted version of the column
			def quoted_column
				ActiveRecord::Base.connection.quote_column_name @column
			end

			def value= val
				@value.value = val
			end

			def value
				@value.value
			end

			def raw_value
				@value.raw_value
			end

			def type= type
				@value.type = type
			end

			def type
				@value.type
			end

			# Returns the filter as a hash
			def to_hash use_raw_value = true
				{@column => {":#{INVERTED_OPERATORS[@operator].to_s}" => use_raw_value ? raw_value : value}}
			end

			# Returns filter as an escaped query string param
			def to_query key="where"
				to_hash.to_query key
			end

			# Returns filter as an unescaped query string param
			def to_s
				URI.unescape to_query
			end

			# Returns the SQL and parameter needed to populate a WHERE clause
			def to_a
				if self.type == :column
					return ["#{quoted_column} #{@operator} #{placeholder}"]
				end
				["#{quoted_column} #{@operator} #{placeholder}", value]
			end

		protected

			# Returns the parameter used to bind the value
			def placeholder
				if ['IN', 'NOT IN'].include? @operator
					'(?)'
				elsif self.type == :column
					value
				else
					'?'
				end
			end

		end

	end
end
