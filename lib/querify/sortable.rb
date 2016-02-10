module Querify
	module Sortable

		# Sorts the query, throwing InvalidDirection exceptions
		def sortable!
			_sortable true
		end

		# Sorts the query, silently ignoring InvalidDirection exceptions
		def sortable
			_sortable false
		end

		protected def _sortable throw_errors

			query = self

			# Sort the query based on :sort from query string
			if Querify.params[:sort]

				Querify.params[:sort].each do |column, direction|
					begin
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
