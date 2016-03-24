require 'test_helper'

describe ActiveRecord::Querify do

	before do
		truncate_db
	end

	describe 'Expressions' do

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

			@sort = ActiveRecord::Querify::Sort.new @expr, :asc

		end

		it 'should filter properly' do
			skip
		end

		it 'should assume the expression is always quoted in filters' do
			assert_equal @popular.column, @statement
			assert_equal @popular.column, @popular.quoted_column
		end

		it 'should assume the expression is always quoted when sorting' do
			assert_equal @sort.column, @statement
			assert_equal @sort.column, @sort.quoted_column
		end

		it 'should generate a proper query string representation' do
			skip
		end

	end

end
