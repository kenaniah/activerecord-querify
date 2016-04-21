module Querify

	# General error class
	class Error < StandardError; end;

	# Thrown when providing a HAVING filter before a GROUP BY clause
	class QueryNotYetGrouped < Error; end;

	# Thrown when an invalid operator is given to a filter
	class InvalidOperator < Error; end

	# Thrown when an invalid direction is given to sort
	class InvalidDirection < Error; end

	# Thrown when in invalid column is passed
	class InvalidColumn < Error
		attr_reader :column
		def initialize column
			super
			@column = column
		end
	end
	class InvalidSortColumn < InvalidColumn; end
	class InvalidFilterColumn < InvalidColumn; end

	# Thrown when an unrecognized type is passed for a column
	class InvalidColumnType < Error; end

	# Raise not specified params error
	class ParameterNotGiven < Error; end

	# Thrown when column does not exist
	class InvalidColumn < Error; end

end
