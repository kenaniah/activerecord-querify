module ActiveRecord
	module Querify
		class Middleware

			def initialize app
				@app = app
			end

			# merges the headers hash into the current header set
			def call env
				status, headers, response = @app.call env
				headers.merge! Querify.headers
				[status, headers, response]
			end

		end
	end
end
