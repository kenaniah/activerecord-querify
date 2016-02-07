module Querify
	module Paginate

		def self.included mod
			mod.instance_eval do
				attr_accessor :_querify_paginated
				_querify_paginated = false
			end
		end

		def paginated?
			_querify_paginated ? true : false
		end

		# Accepts the following options:
		# - :per_page The number of results returned per page (bound by max and min)
		# - :min_per_page The minimum number of results per page
		# - :max_per_page The maximum number of results per page, may be nil for unlimited
		def paginate options = {}

			# Determine config options
			options[:per_page] = options.fetch(:per_page).to_i rescue Querify.config.per_page || 20
			options[:min_per_page] = options.fetch(:min_per_page).to_i rescue Querify.config.min_per_page || 20

			options[:max_per_page] = nil if options[:max_per_page] == 0
			unless options.has_key?(:max_per_page) && options[:max_per_page].nil?
				options[:max_per_page] = options.fetch(:max_per_page).to_i rescue Querify.config.max_per_page
				options[:max_per_page] = 100 if options[:max_per_page].to_i < 1
			end

			# Determine the current page (options overrides params)
			current_page = 1
			if defined? Querify.params[:page]
				current_page = Querify.params[:page].to_i if Querify.params[:page].to_i > 0 rescue current_page
			end
			if options.has_key? :page
				current_page = options[:page].to_i if options[:page].to_i > 0 rescue current_page
			end

			# Determine # of results per page (params overrides options)
			per_page = 0
			if options.has_key? :per_page
				per_page = options[:per_page].to_i rescue per_page
			end
			if defined? Querify.params[:per_page]
				per_page = Querify.params[:per_page].to_i rescue per_page
			end

			# Skip if there is no need to paginate
			return self if options[:max_per_page].nil? && per_page < 1

			# Account for the max & min per page
			per_page = [per_page, options[:max_per_page]].min unless options[:max_per_page].nil?
			per_page = [per_page, options[:min_per_page]].max

			if defined? $response
				$response.headers["X-Per-Page"] = per_page
				$response.headers["X-Current-Page"] = current_page

				# Also set pagination statistic headers when requested
				if Querify.params[:page_stats] == "1"
					total = self.size
					$response.headers['X-Total-Pages'] = (total.to_f / per_page).ceil
					$response.headers['X-Total-Results'] = total
				end
			end

			# Perform limits
			limited = self.limit(per_page).offset(per_page * (current_page - 1))

			# Return the limited query
			limited._querify_paginated = true
			return limited

		end

	end

	# Mix into ActiveRecord
	::ActiveRecord::Base.extend Paginate
	klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
	klasses.each { |klass| klass.send(:include, Paginate)}

end
