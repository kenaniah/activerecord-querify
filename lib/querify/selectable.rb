module Querify

	module Selectable

		# Ignoring the error
		def selectable
			_selectable false
		end
		# Raise any Querify error
		def selectable!
			_selectable true
		end

		protected def _selectable throw_error

			query = self
			# Cancel or raise error if there is no 'select' params
			if !Querify.params["select"]
				if throw_error
					raise Querify::ParameterNotGiven.new, "Select query must be given"
				else
					return nil
				end
			end

			begin
				# Ensure the column exist in the DB
				Querify.params["select"].keys.each do |column|
					unless determine_columns.include?(column)
						raise Querify::InvalidColumn.new(column), "#{column} does not exist"
					end
					# Can't nodify id column
					if column == "id"
						raise Querify::InvalidColumn.new(column), "id column alias is not permitted"
					end
				end

				sql_alias = Querify.params["select"].to_a.map do |column|
					"#{column[0]} AS \"#{column[1]}\""
				end.join(", ")
				# Id hack
					query = query.select("id AS id").select(sql_alias)

				query.as_json

			rescue Querify::Error => err

				if throw_error
					raise err
				end

			end
		end

	end

	# Mix into ActiveRecord
	::ActiveRecord::Base.extend Selectable
	klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
	klasses.each { |klass| klass.send(:include, Selectable)}

end
