module Querify
	module Sortable

		# Sorts the query, throwing InvalidDirection exceptions
		def sortable! allowed_columns: []
			_sortable true, allowed_columns: allowed_columns
		end

		# Sorts the query, silently ignoring InvalidDirection exceptions
		def sortable allowed_columns: []
			_sortable false, allowed_columns: allowed_columns
		end

		protected def _sortable throw_errors, allowed_columns: []

			query = self

			# Prepare the list of allowed columns (if passed)
			allowed_columns = allowed_columns.map &:to_s

			# Sort the query based on :sort from query string
			if Querify.params[:sort]

				Querify.params[:sort].each do |column, direction|

					begin

						column = column.to_s

						# Perform column security
						unless allowed_columns.empty? || allowed_columns.include?(column)
							raise Querify::InvalidSortColumn, "'#{column}' is not a sortable column"
						end

						# Sort the query
						query = query.order Querify::Sort.new(column, direction).to_sql

					rescue Querify::Error => err
						raise err if throw_errors
					end

				end

			end

			# Return the (potentially) sorted query
			return query

		end

		# Mix into ActiveRecord
		::ActiveRecord::Base.extend Sortable
		klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
		klasses.each { |klass| klass.send(:include, Sortable)}

	end
end
