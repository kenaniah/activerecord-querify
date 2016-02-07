require 'rails'

class Querify::Railtie < Rails::Railtie

	config.querify = ActiveSupport::OrderedOptions.new

	initializer "querify.configure" do |app|
		Querify.configure do |config|
			config.per_page = app.config.querify[:per_page]
			config.min_per_page = app.config.querify[:min_per_page]
			config.max_per_page = app.config.querify[:max_per_page]
		end
	end

end
