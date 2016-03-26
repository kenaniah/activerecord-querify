require 'test_helper'

describe ActiveRecord::Querify::Sort do

	# Before is also inherited by child describe blocks
	before do
		truncate_db
		@sort = ActiveRecord::Querify::Sort.new("Column_1", "asc")
	end

	describe 'Sort class unit tests' do
		it 'is a class' do
			assert_kind_of Class, ActiveRecord::Querify::Sort
		end

		it 'has a column getter' do
			assert_equal "Column_1", @sort.column
		end

		it 'has a direction getter' do
			assert_equal "ASC", @sort.direction
		end


		it 'returns the string constant of the direction passed in' do
			assert_equal "ASC", @sort.direction
		end

		it 'throws an error if an invalid direction is passed in' do
			assert_raises ActiveRecord::Querify::InvalidDirection do
				another_sort = ActiveRecord::Querify::Sort.new("Column_1", "elephant")
			end
		end

		it 'returns a safely quoted version of the column' do
			assert_equal "\"Column_1\"", @sort.quoted_column
		end

		it 'returns a hash of the sort' do
			h = {"Column_1"=>":asc"}
			assert_equal h, @sort.to_hash
		end

		it 'returns the query string version of the sort' do
			assert_equal  "sort%5BColumn_1%5D=%3Aasc", @sort.to_query
		end

		it 'returns an unescaped query string param' do
			assert_equal  "sort[Column_1]=:asc", @sort.to_s
		end

		it 'returns the SQL version of the sort' do
			assert_equal "\"Column_1\" ASC", @sort.to_sql
		end

		it 'does not allow access to the protected method #symbolize' do
			assert_raises NoMethodError do
				@sort.symbolize "val"
			end
		end
	end
end
