module Querify

	# Filters the query using :where from the params hash, throwing exceptions
	def filterable! columns: {}, only: false
		_filterable true, columns: columns, only: only
	end
	alias_method :querify!, :filterable!

	# Filters the query using :where from the params hash, silently ignoring exceptions
	def filterable columns: {}, only: false
		_filterable false, columns: columns, only: only
	end
	alias_method :querify, :filterable

	protected def _filterable throw_errors, columns: {}, only: false

		query = self

		# Clear out the existing filters array
		Querify.where_filters = []
		Querify.having_filters = []

		# Prepare the list of allowed columns
		Querify.columns = determine_columns columns: columns, only: only

		# Filter the query based on :where & :having from query string
		[:where, :having].each do |filter_type|

			if Querify.params[filter_type]

				Querify.params[filter_type].each do |column, filters|

					filters.each do |operator, value|

						begin

							column = column.to_s

							# Ensure we're not running HAVING on an ungrouped query
							unless defined?(self.group_values) && !self.group_values.empty?
								raise Querify::QueryNotYetGrouped, "You must provide a GROUP BY clause in order to filter via HAVING" if filter_type == :having
							end

							# Perform column security
							unless Querify.columns.include?(column)
								raise Querify::InvalidFilterColumn, "'#{column}' is not a filterable column"
							end

							# Prefix simple column names when joins are present
							if defined?(self.joins_values) && !self.joins_values.empty? && !column.include?(".")
								column = self.table_name + "." + column
							end

							# Filter the query
							filter = Querify::Filter.new column, operator, value, Querify.columns[column]
							query = query.send filter_type, *filter.to_a

							# Store the filter
							Querify.send(filter_type.to_s + "_filters") << filter

						rescue Querify::Error => err
							raise err if throw_errors
						end

					end

				end

			end

		end

		# Return the (potentially) filtered query
		return query

	end

end
