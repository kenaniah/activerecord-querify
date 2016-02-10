module Querify
	module Sortable

		# Sorts the query, throwing exceptions
		def sortable! columns: {}, only: false
			_sortable true, columns: columns, only: only
		end

		# Sorts the query, silently ignoring exceptions
		def sortable columns: {}, only: false
			_sortable false, columns: columns, only: only
		end

		protected def _sortable throw_errors, columns: {}, only: false

			query = self

			# Clear out the existing sorts array
			Querify.sorts = []

			# Prepare the list of allowed columns
			columns = columns.stringify_keys
			unless only
				columns = _detect_columns.merge columns
			end

			# Sort the query based on :sort from query string
			if Querify.params[:sort]

				Querify.params[:sort].each do |column, direction|

					begin

						column = column.to_s

						# Perform column security
						unless columns.include?(column)
							raise Querify::InvalidSortColumn, "'#{column}' is not a sortable column"
						end

						# Prefix simple column names when joins are present
						if defined?(self.joins_values) && !column.include?(".")
							column = self.table_name + "." + column
						end

						# Sort the query
						sort = Querify::Sort.new(column, direction)
						query = query.order sort.to_sql

						# Add the sort to the sorts array
						Querify.sorts << sort

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
