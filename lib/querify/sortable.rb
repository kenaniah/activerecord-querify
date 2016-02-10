module Querify
	module Sortable

		# Sorts the query, throwing exceptions
		def sortable! allowed_columns: {}, restrict: false
			_sortable true, allowed_columns: allowed_columns, restrict: restrict
		end

		# Sorts the query, silently ignoring exceptions
		def sortable allowed_columns: {}, restrict: false
			_sortable false, allowed_columns: allowed_columns, restrict: restrict
		end

		protected def _sortable throw_errors, allowed_columns: {}, restrict: false

			query = self

			# Prepare the list of allowed columns
			allowed_columns = allowed_columns.stringify_keys
			unless restrict
				allowed_columns = _detect_columns.merge allowed_columns
			end

			# Sort the query based on :sort from query string
			if Querify.params[:sort]

				Querify.params[:sort].each do |column, direction|

					begin

						column = column.to_s

						# Perform column security
						unless allowed_columns.include?(column)
							raise Querify::InvalidSortColumn, "'#{column}' is not a sortable column"
						end

						# Prefix simple column names when joins are present
						if defined?(self.joins_values) && !column.include?(".")
							column = self.table_name + "." + column
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
