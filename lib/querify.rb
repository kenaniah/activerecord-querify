require 'active_support/concern'

module Querify

	extend ActiveSupport::Concern

	included do
	end

	def querify options = {}
		self
	end

end

# Mix into ActiveRecord
::ActiveRecord::Base.extend Querify
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Associations::CollectionProxy]
klasses.each { |klass| klass.send(:include, Querify)}
