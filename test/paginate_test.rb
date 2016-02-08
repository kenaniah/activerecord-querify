require 'test_helper'

describe Querify::Paginate do

	it 'has access to the test dummy model' do
		assert Post
	end

	it 'can be called on AR models' do
		assert_respond_to Post, :paginate
	end

	it 'can be called on AR relations' do
		assert_respond_to Post.first.comments, :paginate
	end

	it 'can be called on AR collection proxies' do
		assert_respond_to Post.all, :paginate
	end

end
