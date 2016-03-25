require 'test_helper'

describe ActiveRecord::Querify::Expression do

	# Before is also inherited by child describe blocks
	before do
		truncate_db
		@@expression = ActiveRecord::Querify::Expression.new("NewExpression", {id:5,foo:"bar"})
	end

	describe 'Filter class unit tests' do
		it 'is a class' do
			assert_kind_of Class, ActiveRecord::Querify::Expression
		end

		it 'has a name getter' do
			skip
		end

		it 'has a params getter' do
			skip
		end

		it 'has a block getter' do
			skip
		end


		it 'can be initialized without params' do
			skip
		end

		it 'can be initialized without a block' do
			skip
		end

		it 'returns itself with the #using method' do
			assert_equal @@expression, @@expression.using
		end

		it 'returns the expressions text' do
			skip
			# assert_equal "some text", @@expression.to_s
		end

	end

end
