module Querify

	class Value

		attr_accessor :value, :type, :operator

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
			@type = type.to_sym
		end

		# Returns the proper value, given the operator
		def parsed_value

			val = @value

			puts "#{val} #{@operator} #{@type}"

			# Return a convertable value
			return REPLACEMENTS[val[1..-1].to_sym] if val =~ /^\:/ && REPLACEMENTS.has_key?(val[1..-1].to_sym)

			# Convert to a list from delimited input if a list type
			val = val.split(',') if ['IN', 'NOT IN'].include?(@operator) && !val.is_a?(Array)

			# Return a search string
			return "%#{val.to_s}%" if ['LIKE', 'ILIKE'].include? @operator

			# Return an integer
			return apply(val, :to_i) if [:integer].include? @type

			# Return a float
			return apply(val, :to_f) if [:decimal, :float].include? @type

			# Return a time
			return apply(apply(val, :to_s), Chronic.method(:parse)) if [:datetime, :timestamp, :time, :date].include? @type

			# Return the value
			return val

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
