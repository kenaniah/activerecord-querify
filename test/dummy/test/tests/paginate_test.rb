require 'test_helper'

describe Querify::Paginate do

	before do
		FactoryGirl.create(:post)
		FactoryGirl.create(:comment)
	end


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

	it 'correctly determines if a query is paginated' do
	end

	it 'uses hardcoded default for per_page settings if no options or config given' do
	end

	it 'uses config for per_page settings if no option given' do
	end

	it 'uses option hash for per_page settings if given' do
	end

	it 'skips pagination if max_per_page is explicitly set to zero or nil' do
	end

	it 'sets max_per_page to 100 if it is given a negative number from the options hash' do
	end

	it 'sets max_per_page to 100 if no limit is given from options and config is set to a negative number' do
	end

	it 'uses the given max_per_page option if it is equal to 1 or higher' do
	end

	it 'uses the max_per_page from config if no max_per_page is explicitly given' do
	end

	it 'returns the first page of results by default' do
	end

	it 'uses the :page option from the params hash to set the page' do
	end

	it 'ignores negative numbers given as the page number' do
	end

	it 'picks up a page option given in the options hash' do
	end

	it 'ignores a negative page number given as part of the options hash' do
	end

	it 'uses the per_page option when it is given' do
	end

	it 'returns 0 results per page if the per_page options is missing' do
	end

	it 'overrides the options with the per_page from the params hash' do
	end

	it 'skips pagination if there is no need to paginate' do
	end

	it 'honors the lower per_page maximum when set' do
	end

	it 'honors the higher per_page mininum when set' do
	end

	it 'sets the per_page HTTP headers for the response when requested' do
	end

	it 'sets the total pages and total results HTTP headers when requested' do
	end


end
