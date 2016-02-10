require 'test_helper'

class PaginationTest < ActionDispatch::IntegrationTest
    include PaginationTestHelper

# Group: No Query String
        test 'uses hardcoded default for per_page settings if no options or config given' do
            Querify.reset_config
            assert_nil Querify.config.per_page
            assert_nil Querify.config.min_per_page
            assert_nil Querify.config.max_per_page

            get "/posts"

            json = JSON.parse(response.body)

            assert_equal 20, json.length

    	end

    	test 'uses config for per_page settings if no option given' do

            configure_querify

            get '/posts'

            json = JSON.parse(response.body)
            assert_equal 20, json.length
    	end

# Group: With Query String

    	test 'returns the per_page number given in query string if it falls between configured max and min' do

            configure_querify

            get '/posts?per_page=27'

            json = JSON.parse(response.body)
            assert_equal 27, json.length
    	end

        test 'configured max_per_page limits the resuts requested by the query string' do

            configure_querify

            get '/posts?per_page=100'

            json = JSON.parse(response.body)
            assert_equal 50, json.length
        end


        test 'min_per_page in query string has no effect' do

            configure_querify

            get '/posts?min_per_page=25'

            json = JSON.parse(response.body)
            assert_equal 20, json.length

        end

        test 'max_per_page in query string has no effect' do

            configure_querify

            get '/posts?max_per_page=15'

            json = JSON.parse(response.body)
            assert_equal 20, json.length

        end

        test 'per_page=nil in query string returns the configured min_per_page' do

            configure_querify

            get '/posts?per_page=nil'

            json = JSON.parse(response.body)
            assert_equal 10, json.length

        end

        test 'returns the correct page' do

            configure_querify

            get '/posts?page=2'

            json = JSON.parse(response.body)
            assert_equal 21, json.first['id']

        end


# Group: Options

    	test 'uses the configured per_page if max_per_page option is negative' do

            configure_querify && clear_params

            posts = Post.paginate(max_per_page: -1)

            assert_equal 20, posts.length

    	end

    	test 'uses configured per_page if min_per_page option is negative' do

            configure_querify && clear_params

            posts = Post.paginate(min_per_page: -1)

            assert_equal 20, posts.length
    	end


    	test 'sets the per_page HTTP headers' do
            configure_querify

            get '/posts'

            assert_equal "20", response.header['X-Per-Page']
            assert_equal "1", response.header['X-Current-Page']

        end

# Group: Complex queries

    test 'it returns the right result from a complex query' do
        configure_querify
        # complex query 

    end


end
