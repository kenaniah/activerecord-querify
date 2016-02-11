require 'chronic'

module Querify

	# Represents an individual predicate to be added to a where clause
	class Predicate

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

		VALUES = {
			true: true,
			false: false,
			nil: nil,
			null: nil,
			blank: '',
			empty: ''
		}.freeze

		def initialize column, operator, value, type

			self.type = type
			self.column = column
			self.value = value
			self.operator = operator

		end

		def operator= op

			if OPERATORS.values.include? op.to_s
				@operator = op.to_s
			else
				@operator = OPERATORS[op.to_sym]
			end

			raise(InvalidOperator, "'#{op}' is not a valid operator") unless @operator

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
			@value = val
		end

		def value
			parse_value @value
		end

		def raw_value
			@value
		end

		def type= type
			@type = type.to_sym
		end

		def type
			@type
		end

		# Returns the predicate as a hash
		def to_hash use_raw_value = true
			{@column => {":#{INVERTED_OPERATORS[@operator].to_s}" => use_raw_value ? raw_value : value}}
		end

		# Returns predicate as an escaped query string param
		def to_query key="where"
			to_hash.to_query key
		end

		# Returns predicate as an unescaped query string param
		def to_s
			URI.unescape to_query
		end

		# Returns the SQL and parameter needed to populate a WHERE clause
		def to_a
			["#{quoted_column} #{@operator} #{placeholder}", value]
		end

	protected

		# Returns the parameter used to bind the value
		def placeholder
			if ['IN', 'NOT IN'].include? @operator
				'(?)'
			else
				'?'
			end
		end

		# Returns the proper value, given the operator
		def parse_value val

			# Return a convertable value
			return VALUES[@value[1..-1].to_sym] if @value =~ /^\:/ && VALUES.has_key?(@value[1..-1].to_sym)

			# Return a search string
			return "%#{@value.to_s}%" if ['LIKE', 'ILIKE'].include? @operator

			# Return an integer
			return @value.to_i if [:integer].include? @type

			# Return a float
			return @value.to_f if [:decimal, :float].include? @type

			# Return a time
			return ::Chronic.parse @value.to_s if [:datetime, :timestamp, :time, :date].include? @type

			# Return a list from delimited input
			return @value.split(@options[:delimiter] || ',') if ['IN', 'NOT IN'].include?(@operator) && !@value.is_a?(Array)

			# Return the value
			return @value

		end

	end

end
