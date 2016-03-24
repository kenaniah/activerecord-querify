require 'test_helper'

describe ActiveRecord::Querify do

	before do
		truncate_db
	end

	describe 'Expressions used in filters' do

		before do

			@statement = "CASE WHEN posts.comments_count > 2 THEN 'Popular' ELSE 'Not Popular' END"

			# Create posts
			@post1 = FactoryGirl.create :post
			@post2 = FactoryGirl.create :post
			@post3 = FactoryGirl.create :post

			# Create comments
			4.times do
				FactoryGirl.create :comment, post: @post1
			end
			3.times do
				FactoryGirl.create :comment, post: @post3
			end

			@expr = ActiveRecord::Querify::Expression.new :popularity do |*args|
				[@statement]
			end

			@popular = ActiveRecord::Querify::Filter.new @expr, :eq, 'Popular', :string
			@not_popular = ActiveRecord::Querify::Filter.new @expr, :eq, 'Not Popular', :string

		end

		it 'should filter properly' do
			skip
		end

		it 'should assume the expression is always quoted' do
			assert_equal @popular.column, @statement
			assert_equal @popular.column, @popular.quoted_column
		end

		it 'should generate a proper query string representation' do
			skip
		end

	end

end
