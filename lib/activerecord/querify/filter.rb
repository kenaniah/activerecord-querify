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
				contains: '@>',
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
					@operator = OPERATORS[Querify.symbolize op]
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
				@column = col
			end

			def column
				@column.to_s
			end

			# Returns a safely quoted version of the column
			def quoted_column
				Querify.quote_column @column
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

				struct = [":#{INVERTED_OPERATORS[@operator]}"]
				if @column.is_a? Querify::Expression
					struct = [*@column.params, *struct]
					struct.unshift ":#{@column.name}"
				else
					struct.unshift @column.to_s
				end

				# Convert the array to a nested hash
				struct.reverse.inject(use_raw_value ? raw_value : value) { |a, n| { n => a } }

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

				# Inject bound parameters if column is an expression
				args = @column.params rescue []

				if self.type == :column
					return ["#{quoted_column} #{@operator} #{placeholder}", *args]
				end
				["#{quoted_column} #{@operator} #{placeholder}", *args, value]
			end

		protected

			# Returns the parameter used to bind the value
			def placeholder
				if ['IN', 'NOT IN'].include? @operator
					'(?)'
				elsif ['@>', '<@'].include? @operator # add better support for arrays
					'ARRAY[?]'
				elsif self.type == :column
					value
				else
					'?'
				end
			end

		end

	end
end
