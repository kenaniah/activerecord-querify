module Querify

	# General error class
	class Error < StandardError; end;

	# Thrown when an invalid operator is given to a filter
	class InvalidOperator < Error; end

	# Thrown when an invalid direction is given to sort
	class InvalidDirection < Error; end

	# Thrown when in invalid column is passed
	class InvalidColumn < Error; end

	# Thrown when an unrecognized type is passed for a column
	class InvalidColumnType < Error; end

	class InvalidSortColumn < InvalidColumn; end;

	class InvalidFilterColumn < InvalidColumn; end;

end
