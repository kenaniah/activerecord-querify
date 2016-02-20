# Set up rails environment
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../dummy/db/migrate", __FILE__)]

# Enables spec test syntax
require "minitest/autorun"

# Rails test helpers
require "rails/test_help"

# Set up the minitest reporter
Minitest::Reporters.use!(
	[Minitest::Reporters::SpecReporter.new],
	ENV,
	Minitest.backtrace_filter
)

# Filter out Minitest backtrace
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

def truncate_db
	Author.destroy_all
	Post.destroy_all
	Comment.destroy_all
end
