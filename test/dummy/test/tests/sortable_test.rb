require 'test_helper'

describe Querify::Sortable do

	it 'is a module' do
        assert_kind_of Module, Sortable
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

	it 'correctly determines if query is sortable' do
	end

	it 'sorts by column name provided' do
	end

	it 'orders by order options provided' do
	end

	it 'orders by ascending if no order option provided' do
	end

	it 'ignores sort options passed in as an array' do
	end

	it 'ignores order options passed in as an array' do
	end


end
