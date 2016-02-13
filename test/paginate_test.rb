require 'test_helper'

describe Querify::Paginate do

	before(:all) do
		100.times do
			FactoryGirl.create(:post)
		end
	end

	it 'ActiveRecord responds to paginate' do
		assert_respond_to Post, :paginate
		assert_respond_to Post.all.first.comments, :paginate
	end

	it 'ActiveRecord knows the query is paginated' do
		assert Post.paginate.paginated?
		assert_equal false, Post.paginated?
	end

end
