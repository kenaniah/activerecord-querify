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

			# Additional comments for multi-sorting
			FactoryGirl.create :comment, post: @one
			FactoryGirl.create :comment, post: @two

			@multi = [@two, @one, @three, @four]

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

		it 'sorts multiple columns' do

			Querify.params = {sort: {"comments_count" => "desc", "name" => "desc"}}
			assert_equal @multi, Post.sortable.to_a

		end

		it '#sortable ignores non-available columns' do

			Querify.params = {sort: {"foobar" => "desc", "name" => "desc"}}
			assert_equal @descending, Post.sortable.to_a

		end

		it '#sortable! errors on non-available columns' do

			Querify.params = {sort: {"foobar" => "desc", "name" => "desc"}}
			assert_raises Querify::InvalidSortColumn do
				Post.sortable!.to_a
			end

		end

		it '#sortable ignores bad operators' do

			Querify.params = {sort: {"comments_count" => "adfkldsflk", "name" => "desc"}}
			assert_equal @descending, Post.sortable.to_a

		end

		it '#sortable! errors on bad operators' do

			Querify.params = {sort: {"comments_count" => "adfkldsflk", "name" => "desc"}}
			assert_raises Querify::InvalidDirection do
				Post.sortable!.to_a
			end

		end

	end


end
