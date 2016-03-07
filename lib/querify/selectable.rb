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
			if !Querify.params[:select]
				if throw_error
					raise Querify::ParameterNotGiven.new, "Params must be given"
				else
					return nil
				end
			end

			begin

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
