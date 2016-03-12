require 'chronic'

module ActiveRecord
	module Querify

		# Represents an individual column to be added to the order by clause
		class Sort

			DIRECTIONS = {
				asc: 'ASC',
				desc: 'DESC',
				ascnf: 'ASC NULLS FIRST',
				ascnl: 'ASC NULLS LAST',
				descnf: 'DESC NULLS FIRST',
				descnl: 'DESC NULLS LAST'
			}.freeze

			INVERTED_DIRECTIONS = DIRECTIONS.dup.invert.freeze

			def initialize column, direction

				self.column = column
				self.direction = direction

			end

			def direction= dir

				if DIRECTIONS.values.include? dir.to_s.upcase
					@direction = dir.to_s.upcase
				else
					@direction = DIRECTIONS[symbolize dir]
				end

				raise(InvalidDirection, "'#{dir}' is not a valid direction") unless @direction

				@direction

			end

			def direction
				@direction
			end

			def column= col
				@column = col.to_s
			end

			def column
				@column
			end

			# Returns a safely quoted version of the column
			def quoted_column

				# Check to see if our column is a prefix
				table, col = @column.split ".", 2

				if col.nil?
					field = ActiveRecord::Base.connection.quote_column_name @column
				else
					field = ActiveRecord::Base.connection.quote_table_name table
					field += "."
					field += ActiveRecord::Base.connection.quote_column_name col
				end

				field

			end

			# Returns the filter as a hash
			def to_hash
				{@column => ":#{INVERTED_DIRECTIONS[@direction].to_s}"}
			end

			# Returns filter as an escaped query string param
			def to_query key="sort"
				to_hash.to_query key
			end

			# Returns filter as an unescaped query string param
			def to_s
				URI.unescape to_query
			end

			# Returns the SQL needed to populate an ORDER BY clause
			def to_sql
				"#{quoted_column} #{@direction}"
			end

		protected

			def symbolize val
				return val if val.is_a? Symbol
				val[1..-1].to_sym
			end

		end

	end
end