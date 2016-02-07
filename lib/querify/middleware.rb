module Querify
	class Middleware

		def initialize app
			@app = app
		end

		# merges the headers hash into the current header set
		def call env
			req = Rack::Request.new env
			status, headers, response = @app.call env
			headers.merge! Querify.headers
			[status, headers, response]
		end

	end
end
