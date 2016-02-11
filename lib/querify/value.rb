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

			# Return a convertable value
			return REPLACEMENTS[@value[1..-1].to_sym] if @value =~ /^\:/ && REPLACEMENTS.has_key?(@value[1..-1].to_sym)

			# Return a search string
			return "%#{@value.to_s}%" if ['LIKE', 'ILIKE'].include? @operator

			# Return an integer
			return @value.to_i if [:integer].include? @type

			# Return a float
			return @value.to_f if [:decimal, :float].include? @type

			# Return a time
			return ::Chronic.parse @value.to_s if [:datetime, :timestamp, :time, :date].include? @type

			# Return a list from delimited input
			return @value.split(',') if ['IN', 'NOT IN'].include?(@operator) && !@value.is_a?(Array)

			# Return the value
			return @value

		end

	end

end
