require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
    # Test in several groups
    # 1. No query string
    # - get according to defaults
    # - get according to specific configs
    # - get if only some configs set and others nil
    # 2. Query string
    # - get with some query string set
    # - check whether query string overrides config
    # 3. Options Hash
    # - get with some options set and no query string
    # - get with some options and query string set to see what overrides
    # - get with config hash, options, query string...

    # and check specific conditions as outlined by tests below 





    	test 'this is how the tests should run' do
            get '/posts?sort[name]=asc&sort[id]=desc'
            json = JSON.parse(response.body)
    	end

        test 'uses hardcoded default for per_page settings if no options or config given' do
            Querify.reset_config

            get "/posts"

            json = JSON.parse(response.body)

            assert_equal 20, json.length

    	end

    	# test 'uses config for per_page settings if no option given' do
        #     Querify.config.per_page = 10
        #     Querify.config.min_per_page = 5
        #     Querify.config.max_per_page = 20
        #
        #     get '/posts'
        #
        #     json = JSON.parse(response.body)
        #     assert_equal 10, json.length
    	# end

    	test 'uses per_page settings if given' do
            get '/posts?per_page=6'

            json = JSON.parse(response.body)
            assert_equal 5, json.length
    	end

    	test 'skips pagination and returns 100 results if max_per_page is explicitly set to zero' do

            get '/posts?max_per_page=0'

            json = JSON.parse(response.body)
            assert_equal 100, json.length

        end

        # Should I test the hierarchy of config options?

    	test 'sets max_per_page to 100 if it is given a negative number from the overriding options hash' do
            posts = Post.paginate(max_per_page: -1)

            assert_equal 100, posts.length

    	end

    	test 'sets max_per_page to 100 if no limit is given from options and config is set to a negative number' do
    	end

    	test 'uses the given max_per_page option if it is equal to 1 or higher' do
    	end

    	test 'uses the max_per_page from config if no max_per_page is explicitly given' do
    	end

    	test 'returns the first page of results by default' do
    	end

    	test 'uses the :page option from the params hash to set the page' do
    	end

    	test 'ignores negative numbers given as the page number' do
    	end

    	test 'picks up a page option given in the options hash' do
    	end

    	test 'ignores a negative page number given as part of the options hash' do
    	end

    	test 'uses the per_page option when it is given' do
    	end

    	test 'returns 0 results per page if the per_page options is missing' do
    	end

    	test 'overrides the options with the per_page from the params hash' do
    	end

    	test 'skips pagination if there is no need to paginate' do
    	end

    	test 'honors the lower per_page maximum when set' do
    	end

    	test 'honors the higher per_page mininum when set' do
    	end

    	test 'sets the per_page HTTP headers for the response when requested' do
    	end

    	test 'sets the total pages and total results HTTP headers when requested' do
    	end

end
