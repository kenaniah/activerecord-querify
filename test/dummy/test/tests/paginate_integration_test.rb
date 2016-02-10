require 'test_helper'

class PaginationTest < ActionDispatch::IntegrationTest
    include PaginationTestHelper

    def setup
        configure_querify
    end

# Group: No Query String

        test 'uses hardcoded default for per_page settings if no options or config given' do
            Querify.reset_config
            assert_nil Querify.config.per_page
            assert_nil Querify.config.min_per_page
            assert_nil Querify.config.max_per_page

            get "/posts"

            # Default page length
            assert_equal 20, jsonify.length

            # Ensure we are on the first page of results
            assert_equal 1, jsonify.first['id']

    	end

    	test 'uses config for per_page settings if no option given' do
            get '/posts'

            assert_equal 20, jsonify.length
    	end


# Group: With Query String

    	test 'returns the per_page number given in query string if it falls between configured max and min' do

            get '/posts?per_page=27'

            assert_equal 27, jsonify.length
    	end

        test 'configured max_per_page limits the resuts requested by the query string' do

            get '/posts?per_page=100'

            assert_equal 50, jsonify.length
        end


        test 'min_per_page in query string has no effect' do

            get '/posts?min_per_page=25'

            assert_equal 20, jsonify.length

        end

        test 'max_per_page in query string has no effect' do

            get '/posts?max_per_page=15'

            assert_equal 20, jsonify.length

        end

        test 'per_page=nil in query string returns the configured min_per_page' do

            get '/posts?per_page=nil'

            assert_equal 10, jsonify.length

        end

        test 'returns the correct page' do

            get '/posts?page=2'

            jsonify

            assert_equal 21, jsonify.first['id']

        end


# Group: Options

    	test 'uses the configured per_page if max_per_page option is negative' do

            clear_params

            posts = Post.paginate(max_per_page: -1)

            assert_equal 20, posts.length

    	end

    	test 'uses configured per_page if min_per_page option is negative' do

            clear_params

            posts = Post.paginate(min_per_page: -1)

            assert_equal 20, posts.length
    	end


    	test 'sets the page stats HTTP headers if requested' do

            get '/posts?page_total_stats=1'

            assert_equal "20", response.header['X-Per-Page']
            assert_equal "1", response.header['X-Current-Page']
            assert_equal (Post.count.to_f/20).ceil, response.header['X-Total-Pages'].to_i
            assert_equal Post.count, response.header['X-Total-Results'].to_i

        end

        test 'setting max_per_page option to nil disables the maximum' do
            clear_params

            posts = Post.paginate(max_per_page: nil, per_page: 60)

            assert_equal 60, posts.length

        end

        test 'setting min_per_page option to 0 disables the minimum' do
            clear_params

            posts = Post.paginate(min_per_page: 0, per_page: 1)

            assert_equal 1, posts.length

        end

        test 'pagination defaults to the min if per_page is set to 0 in query string' do
            get '/posts?per_page=0'

            assert_equal Querify.config.min_per_page, jsonify.length

        end


        test '#paginated? method reveals whether query is paginated' do

            a = Post.all
            b = Post.all.paginate

            assert_not a.paginated?
            assert b.paginated?

        end

        test 'does not set the per_page HTTP headers unless requested' do

            get '/posts'

            assert_equal "20", response.header['X-Per-Page']
            assert_equal "1", response.header['X-Current-Page']
            assert_nil response.header['X-Total-Pages']
            assert_nil response.header['X-Total-Results']
        end


# Group: Complex queries

    test 'it returns the right result from a complex query' do
        get '/posts?per_page=33&page=2'

        assert_equal 34, jsonify.first['id']
        assert_equal 33, jsonify.length
    end

end
