require 'test_helper'

describe Querify::Sortable do

	# Before is also inherited by child describe blocks
	before do
		truncate_db
	end

	it 'is a module' do
        assert_kind_of Module, Querify::Sortable
    end

	it 'has access to the test dummy model' do
		assert Post
	end

	it 'can be called on AR models' do
		assert_respond_to Post, :sortable
	end

	it 'can be called on AR relations' do
		FactoryGirl.create :post
		assert_respond_to Post.first.comments, :sortable
	end

	it 'can be called on AR collection proxies' do
		assert_respond_to Post.all, :sortable
	end

	describe 'sorting' do

		before do

			@one = FactoryGirl.create :post, name: "First post"
			@two = FactoryGirl.create :post, name: "Second post"
			@three = FactoryGirl.create :post, name: "Third post"
			@four = FactoryGirl.create :post, name: "Fourth post"

			@ascending = [@one, @four, @two, @three]
			@descending = [@three, @two, @four, @one]

		end

		it 'only has 4 posts for testing' do
			assert_equal 4, Post.count
		end

		it 'sorts by ascending column names' do

			Querify.params = {sort: {"name" => "asc"}}
			assert_equal @ascending, Post.sortable.to_a

			Querify.params = {sort: {"name" => :asc}}
			assert_equal @ascending, Post.sortable.to_a

			Querify.params = {sort: {"name" => ":asc"}}
			assert_equal @ascending, Post.sortable.to_a

		end

		it 'sorts by descending column names' do

			Querify.params = {sort: {"name" => "desc"}}
			assert_equal @descending, Post.sortable.to_a

			Querify.params = {sort: {"name" => :desc}}
			assert_equal @descending, Post.sortable.to_a

			Querify.params = {sort: {"name" => ":desc"}}
			assert_equal @descending, Post.sortable.to_a

		end

	end


end
