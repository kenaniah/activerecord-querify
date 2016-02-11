require 'test_helper'

describe Querify::Sortable do

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
		assert_respond_to Post.first.comments, :sortable
	end

	it 'can be called on AR collection proxies' do
		assert_respond_to Post.all, :sortable
	end


end
