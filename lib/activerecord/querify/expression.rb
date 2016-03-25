module ActiveRecord

	module Querify

		class Expression

			attr_reader :type
			attr_reader :name
			attr_reader :params
			attr_reader :block

			def initialize type, name = nil, params = nil, &block

				self.type = type
				self.name = name
				@block = block
				@params = params unless params.nil?

			end

			def type= val
				@type = val.to_sym
				unless Querify::Value::TYPES.include? @type
					raise ArgumentError, "Expression's was not passed a valid database type"
				end
			end

			def name= val
				@name = val.to_sym rescue nil
			end

			def using *params
				@params = params
				self
			end

			# Returns the expression text and any bound values
			def to_a

				res = @block.call *@params

				# Convert to an array if string
				return [res] if res.class == String

				# Return the array
				return res

			end

			# Returns the expression's text
			def to_s
				self.to_a[0]
			end

		end

	end

end
