module ActiveRecord
	module Querify

		# Filters the query using :where from the params hash, throwing exceptions
		def filterable! expressions: {}, columns: {}, only: false
			_filterable true, expressions: expressions, columns: columns, only: only
		end
		alias_method :querify!, :filterable!

		# Filters the query using :where from the params hash, silently ignoring exceptions
		def filterable expressions: {}, columns: {}, only: false
			_filterable false, expressions: expressions, columns: columns, only: only
		end
		alias_method :querify, :filterable

		protected def _filterable throw_errors, expressions: {}, columns: {}, only: false

			query = self

			# Clear out the existing filters array
			Querify.where_filters = []
			Querify.having_filters = []

			# Prepare the list of allowed columns
			Querify.columns = determine_columns columns: columns, only: only

			# Sanity check the expressions hash & ensure the names are set
			expressions.each do |name, expr|
				unless expr.is_a? Querify::Expression
					raise ArgumentError, "Expressions must be instances of Querify::Expression"
				end
				expr.name = name
			end

			# Filter the query based on :where & :having from query string
			Querify.flatten_params.each do |filter_type, field, *args, operator, value|

				# Skip anything that's not :where or :having
				next unless [:where, :having].include? filter_type

				# Ensure string
				field = "#{field}"

				begin

					# Determine if a column or an expression
					if field[0] == ":"

						# The field represents an expression

						# Chomp the first character
						field.slice! 0
						field = field.to_sym

						# Check to see if the expression exists
						unless expressions.has_key? field
							raise Querify::InvalidFilterColumn.new(field), "':#{field}' is not a registered filterable expression"
						end

						# Configure the expression
						expr = expressions[field]
						expr.using(*args)

						# Filter the query
						filter = Querify::Filter.new expr, operator, value, expr.type
						query = query.send filter_type, *filter.to_a

						# Store the filter
						Querify.send(filter_type.to_s + "_filters") << filter

					else

						# The field represents a column

						# Ensure we're not running HAVING on an ungrouped query
						unless defined?(self.group_values) && !self.group_values.empty?
							if filter_type == :having
								raise Querify::QueryNotYetGrouped, "You must provide a GROUP BY clause in order to filter via HAVING"
							end
						end

						# Perform column security
						unless Querify.columns.include?(field)
							raise Querify::InvalidFilterColumn.new(field), "'#{field}' is not a filterable column"
						end

						# Prefix simple column names when joins are present
						if defined?(self.joins_values) && !self.joins_values.empty? && !field.include?(".")
							field = self.table_name + "." + field
						end

						# Filter the query
						filter = Querify::Filter.new field, operator, value, Querify.columns[field]
						query = query.send filter_type, *filter.to_a

						# Store the filter
						Querify.send(filter_type.to_s + "_filters") << filter

					end

				rescue Querify::Error => err
					raise err if throw_errors
				end

			end

			# Return the (potentially) filtered query
			return query

		end

	end
end
