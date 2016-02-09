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

			# Reset the headers array
			Querify.headers = {}
			# Determine config

			options[:per_page] = options.fetch(:per_page).to_i rescue Querify.config.per_page || 20
			binding.pry
			options[:min_per_page] = options.fetch(:min_per_page).to_i rescue Querify.config.min_per_page || 20
			options[:max_per_page] = determine_max options

			current_page = determine_current_page options
			per_page = determine_per_page options

			# Skip pagination if there is no need to paginate
			return self if options[:max_per_page].nil? && per_page < 1

			# Adjust :per_page to honor the minimum and maximum (when set)
			per_page = [per_page, options[:max_per_page]].min unless options[:max_per_page].nil?
			per_page = [per_page, options[:min_per_page]].max


			# Set the pagination meta headers to be returned with the HTTP response

			Querify.headers["X-Per-Page"] = per_page.to_s
			Querify.headers["X-Current-Page"] = current_page.to_s


			# Also set pagination counted headers when requested
			if ["1", "yes", "true", "on"].include? Querify.params[:page_total_stats]
				total = self.size
				Querify.headers['X-Total-Pages'] = (total.to_f / per_page).ceil.to_s
				Querify.headers['X-Total-Results'] = total.to_s
			end

			# Paginate the query
			paginated = self.limit(per_page).offset(per_page * (current_page - 1))

			# Mark the paginated query as paginated
			paginated._querify_paginated = true

			# Return it
			return paginated

		end

		private

		# Determines the max per page option (options overrides params)
		def determine_max options

			max = options[:max_per_page]

			# Treat 0 the same as nil
			max = nil if max == 0
			# If :max_per_page is not explicitly nil, parse it
			unless options.has_key?(:max_per_page) && max.nil?
				max = options.fetch(:max_per_page).to_i rescue Querify.config.max_per_page
				max = 100 if max.to_i < 1
			end
			# Return it
			return max

		end

		# Determines the number of results per page (params overrides options)
		def determine_per_page options
			# Assume 0 if the :per_page option is not provided or unparsable
			per_page = options[:per_page].to_i rescue 0

			# Override using the params hash if parsable
			if defined? Querify.params[:per_page]
				per_page = Querify.params[:per_page].to_i rescue per_page
			end
			# Return it
			return per_page

		end

		# Determines which page number to return
		def determine_current_page options

			# Default to the first page
			current_page = 1

			# Read the :page from the params hash provided it's a positive integer
			if defined? Querify.params[:page]
				current_page = Querify.params[:page].to_i if Querify.params[:page].to_i > 0 rescue current_page
			end

			# If :page was passed in as an option to #paginate, use it as an override
			if options.has_key? :page
				current_page = options[:page].to_i if options[:page].to_i > 0 rescue current_page
			end

			# Return it
			return current_page

		end

	end

	# Mix into ActiveRecord
	::ActiveRecord::Base.extend Paginate
	klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
	klasses.each { |klass| klass.send(:include, Paginate)}

end
