module Querify
	module Paginate

		# Accepts the following options:
		# - :per_page The number of results returned per page (bound by max and min)
		# - :min_per_page The minimum number of results per page
		# - :max_per_page The maximum number of results per page, may be nil for unlimited
		def paginate options = {}

			# Determine config options
			options[:per_page] = options.fetch(:per_page).to_i rescue Querify.config.per_page || 20
			options[:min_per_page] = options.fetch(:min_per_page).to_i rescue Querify.config.min_per_page || 20
			options[:max_per_page] = options.fetch(:max_per_page).to_i rescue Querify.config.max_per_page || 100

			puts "options: #{options}"

			# Determine the current page
			current_page = 1
			current_page = $params[:page].to_i if $params[:page].to_i > 0

			# Determine results per page
			per_page = $params[:per_page].to_i if $params[:per_page].to_i != 0

			# Skip if there is no need to paginate
			return self if max_per_page.nil? && per_page < 0

			# Account for the max & min per page
			per_page = [per_page, options[:max_per_page]].min unless options[:max_per_page].nil?
			per_page = [per_page, options[:min_per_page]].max
			$response.headers["X-Per-Page"] = per_page
			$response.headers["X-Current-Page"] = current_page

			# Also set pagination statistic headers when requested
			if $params[:page_stats] == "1"
				total = self.size
				$response.headers['X-Total-Pages'] = (total.to_f / per_page).ceil
				$response.headers['X-Total-Results'] = total
			end

			# Perform limits
			limited = self.limit(per_page).offset(per_page * (current_page - 1))

			# Return the limited query
			return limited

		end

	end

end
