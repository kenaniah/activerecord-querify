module Querify
	module Sortable

		def sortable

			query = self

			# Sort the query based :sort and :order from query string
			if Querify.params[:sort]

				sort = Querify.params[:sort]
				sort = sort.to_s.split(",") unless sort.class == Array

				order = Querify.params[:order] || []
				order = order.to_s.split(",") unless order.class == Array

				# Apply the sorts
				sort.each_with_index do |col, i|

					col = Integer(col) rescue ActiveRecord::Base.connection.quote_column_name(col)
					direction = order[i].to_s.downcase == "desc" ? "DESC" : "ASC"

					query = query.order "#{col} #{direction}"

				end

			end

			query

		end

		# Mix into ActiveRecord
		::ActiveRecord::Base.extend Sortable
		klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
		klasses.each { |klass| klass.send(:include, Sortable)}

	end
end
