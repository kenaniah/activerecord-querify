module ActiveRecord

	module Querify

		class Expression

			attr_reader :name
			attr_reader :params
			attr_reader :block

			def initialize name, params = nil, &block

				@name = name
				@block = block
				@params = params unless params.nil?

			end

			def using *params
				@params = params
				self
			end

			# Returns the expression text and any bound values
			def to_a

				res = @block.call *@params

				# Convert to an array if string
				return [res] if res.class = String

				# Return the array
				return res

			end

			# Returns the expression's text
			def to_s
				self.to_a[0]
			end

		end

		class Expression

			Sum = Expression.new :sum do |*args|
				["SUM(?)", args.map(&:to_f)]
			end
			Average = Expression.new :average do |*args|
				["AVERAGE(?)", args.map(&:to_f)]
			end
			Count = Expression.new :count do |*args|
				args = ['*'] unless args.count > 0
				["COUNT(?)", args]
			end

		end

	end

end
