require 'test_helper'

describe Querify::Sortable do

	# Before is also inherited by child describe blocks
	before do
		truncate_db
	end

	describe 'Sortable module sanity tests' do

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

		describe 'sorting with no params' do

			it 'does not add to query array if no sortable params given' do

				Querify.params = {sort: {}}
				Post.sortable
				assert_empty Querify.sorts

			end

		end

		describe 'sorting with one sortable parameter' do

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

			# Enable these tests when database is pg, not sqlite3

			# it 'sorts by ascending nulls first' do
			# 	Post.first.update(name: nil)
			# 	Querify.params = {sort: {"name" => :ascnf}}
			# 	p = Post.sortable.to_a
			#
			# 	assert_nil p[0].name
			# 	assert p[1].name < p[2].name
			#
			# end
			#
			# it 'sorts by ascending nulls last' do
			# 	Post.first.update(name: nil)
			# 	Querify.params = {sort: {"name" => :ascnl}}
			# 	p = Post.sortable.to_a
			#
			# 	assert_nil p[3].name
			# 	assert p[1].name < p[2].name
			# end
			#
			# it 'sorts by descending nulls first' do
			# 	Post.first.update(name: nil)
			# 	Querify.params = {sort: {"name" => :descnf}}
			# 	p = Post.sortable.to_a
			#
			# 	assert_nil p[0].name
			# 	assert p[1].name > p[2].name
			#
			# end
			#
			# it 'sorts by descending nulls last' do
			# 	Post.first.update(name: nil)
			# 	Querify.params = {sort: {"name" => :descnl}}
			# 	p = Post.sortable.to_a
			#
			# 	assert_nil p[3].name
			# 	assert p[1].name > p[2].name
			# end

			it 'sorts multiple columns' do

				Querify.params = {sort: {"comments_count" => "desc", "name" => "desc"}}
				assert_equal @multi, Post.sortable.to_a
				assert_equal 2, Querify.sorts.count

			end

			it '#sortable ignores non-available columns' do

				Querify.params = {sort: {"foobar" => "desc", "name" => "desc"}}
				assert_equal @descending, Post.sortable.to_a
				assert_equal 1, Querify.sorts.count

			end

			it '#sortable ignores bad operators' do

				Querify.params = {sort: {"comments_count" => "adfkldsflk", "name" => "desc"}}
				assert_equal @descending, Post.sortable.to_a
				assert_equal 1, Querify.sorts.count

			end

			it 'honors column security' do

				Querify.params = {sort: {"comments_count" => "desc", "name" => "desc"}}
				assert_equal @descending, Post.sortable(columns: {name: :text}, only: true).to_a
				assert_equal 1, Querify.sorts.count

			end

			it 'adds sorts to the sorts array when given a single sort' do

				Querify.params = {sort: {"comments_count" => "desc"}}
				Post.sortable
				assert Querify.sorts[0].column = "comments_count" && Querify.sorts[0].direction = "DESC"

			end

			it 'sorts using joins' do

				Querify.params = {sort: {"id" => "asc"}}
				p = Post.joins(:comments).sortable

				# Query should only return two results because only two posts have comments
				assert_equal 2, p.length
				assert p[0].id < p[1].id

			end

		end

		describe 'sorting with multiple parameters' do

			it 'adds sorts to the sorts array when given two sorts' do

				Querify.params = {sort: {"comments_count" => "desc", "author_id" => "desc"}}
				Post.sortable
				assert Querify.sorts[0].column = "comments_count" && Querify.sorts[0].direction = "DESC"
				assert Querify.sorts[1].column = "author_id" && Querify.sorts[1].direction = "DESC"

			end

		end

		describe 'sortable!' do

			it '#sortable! errors on non-available columns' do

				Querify.params = {sort: {"foobar" => "desc", "name" => "desc"}}
				assert_raises Querify::InvalidSortColumn do
					Post.sortable!.to_a
				end

			end

			it '#sortable! errors on bad operators' do

				Querify.params = {sort: {"comments_count" => "adfkldsflk", "name" => "desc"}}
				assert_raises Querify::InvalidDirection do
					Post.sortable!.to_a
				end

			end
		end

	end
end
