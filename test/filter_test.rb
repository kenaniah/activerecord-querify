require 'test_helper'

describe ActiveRecord::Querify::Filter do

	# Before is also inherited by child describe blocks
	before do
		truncate_db
		@filter = ActiveRecord::Querify::Filter.new("id", "IN", [1,3], :integer)
	end

	describe 'Filter class unit tests' do
		it 'is a class' do
			assert_kind_of Class, ActiveRecord::Querify::Filter
		end

		it 'has a column getter' do
			assert_equal "id", @filter.column
		end

		it 'has a operator getter' do
			assert_equal "IN", @filter.operator
		end

		it 'throws an error if given an invalid operator' do
			assert_raises ActiveRecord::Querify::InvalidOperator do
				another_filter = ActiveRecord::Querify::Filter.new("id", "elephant", [1,3], :integer)
			end
		end

		it 'returns a safely quoted version of the column' do
			assert_equal "\"id\"", @filter.quoted_column
		end

		it "has a value getter" do
			assert_equal [1,3], @filter.value
		end

		it "has a raw value getter" do
			assert_equal [1,3], @filter.raw_value
		end

		it "has a type getter" do
			assert_equal :integer, @filter.type
		end

		it "returns the filter as a hash" do
			h = {"id"=>{":in"=>[1, 3]}}
			assert_equal h, @filter.to_hash
		end

		it "returns the filter as an unescaped query string" do
			assert_equal "where[id][:in][]=1&where[id][:in][]=3", @filter.to_s
		end

		it "returns an escaped query string" do
			assert_equal "where%5Bid%5D%5B%3Ain%5D%5B%5D=1&where%5Bid%5D%5B%3Ain%5D%5B%5D=3", @filter.to_query
		end

		it "returns the SQL and parameter needed to populate a WHERE clause" do
			assert_equal ["\"id\" IN (?)", [1, 3]], @filter.to_a
		end

		it "does not allow access to the protected #placeholder method" do
			assert_raises NoMethodError do
				@filter.placeholder
			end
		end
	end
end
