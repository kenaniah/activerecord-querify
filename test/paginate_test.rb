require 'test_helper'

describe Querify::Paginate do

	before(:all) do
		FactoryGirl.create(:post)
	end

	it 'ActiveRecord responds to #paginate' do
		assert_respond_to Post, :paginate
		assert_respond_to Post.all, :paginate
		assert_respond_to Post.first.comments, :paginate
	end

	it 'ActiveRecord responds to #paginated?' do
		assert_respond_to Post, :paginated?
		assert_respond_to Post.all, :paginated?
		assert_respond_to Post.first.comments, :paginated?
	end

	it 'ActiveRecord knows if the query is paginated' do
		assert Post.paginate.paginated?
		assert_equal false, Post.paginated?
	end

end
