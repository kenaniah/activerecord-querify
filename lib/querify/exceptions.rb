module Querify

	# General error class
	class Error < StandardError; end;

	# Thrown when an invalid operator is given to predicate
	class InvalidOperator < Error; end

	# Thrown when an invalid direction is given to sort
	class InvalidDirection < Error; end

end
