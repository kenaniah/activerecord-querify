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

		# Clear out the existing predicates array
		Querify.predicates = []


		# Prepare the list of allowed columns
		columns = columns.stringify_keys
		unless only
			columns = _detect_columns.merge columns
		end

		# Filter the query based on :where from query string
		if Querify.params[:where]

			Querify.params[:where].each do |column, filters|

				filters.each do |operator, value|

					begin

						column = column.to_s

						# Perform column security
						unless columns.include?(column)
							raise Querify::InvalidFilterColumn, "'#{column}' is not a filterable column"
						end

						# Prefix simple column names when joins are present
						if defined?(self.joins_values) && !self.joins_values.empty? && !column.include?(".")
							column = self.table_name + "." + column
						end

						# Filter the query
						predicate = Querify::Predicate.new column, operator, value, columns[column]
						query = query.where(*predicate.to_a)

						# Store the predicate
						Querify.predicates << predicate

					rescue Querify::Error => err
						raise err if throw_errors
					end

				end

			end

		end

		# Return the (potentially) filtered query
		return query

	end

end
