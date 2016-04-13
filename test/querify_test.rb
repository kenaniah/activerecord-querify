require 'test_helper'

describe ActiveRecord::Querify do

	describe "quote_column" do

		it 'properly quotes unqualified columns' do
			assert_equal '"col"', ActiveRecord::Querify.quote_column("col")
		end

		it 'properly quotes table-qualified columns' do
			assert_equal '"table"."col"', ActiveRecord::Querify.quote_column("table.col")
		end

		it 'properly quotes schema-qualified columns' do
			assert_equal '"schema"."table"."col"', ActiveRecord::Querify.quote_column("schema.table.col")
		end

	end

end
