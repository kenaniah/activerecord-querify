# Set up rails environment
require File.expand_path("dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __FILE__)]

# Enables spec test syntax
require "minitest/autorun"

# Set up the minitest reporter
Minitest::Reporters.use!(
	[Minitest::Reporters::SpecReporter.new],
	ENV,
	Minitest.backtrace_filter
)
