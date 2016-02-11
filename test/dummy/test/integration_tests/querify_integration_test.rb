require 'test_helper'

class QuerifyIntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper

    def setup
        setup_data
    end

    def teardown
        teardown_data
    end


	test 'it returns greater than' do

		get '/posts?where[name][gt]=aaa'
		assert_equal jsonify.length, Post.where("name > ?",'aaa').length

	end

	test 'it returns less than' do

		get '/posts?where[name][lt]=ZZZ'

		assert_equal jsonify.length, Post.where("name < ?",'ZZZ').paginate.length

	end

    test 'returns greater than or equal to' do

        get '/posts?where[id][gt]=50'
        assert_equal jsonify.first['id'], 51
        assert_equal jsonify[1]['id'], 52

    end

    test 'returns less than or equal to' do

        get '/posts?where[id][lteq]=5'
        assert_equal jsonify.first['id'], 1
        assert_equal jsonify.last['id'], 5

    end

    test 'returns equal to' do

        get '/posts?where[id][eq]=5'
        assert_equal jsonify.first['id'], 5
        assert_equal jsonify.length, 1

    end

    test 'returns not equal to' do

        get '/posts?where[id][neq]=1'
        assert_equal jsonify.first['id'], 2

    end

    test 'returns is' do

        get '/posts?where[id][is]=5'
        assert_equal jsonify.first['id'], 5
        assert_equal jsonify.length, 1

    end

    test 'returns is not' do

        get '/posts?where[id][isnot]=1'
        assert_equal jsonify.first['id'], 2

    end


    test 'returns like' do
        get '/posts?where[name][like]=10'

        jsonify.map do |json|
            assert json['name'].count('10') >=2 #count returns 2 if 10 is found because 10 has 2 characters
        end

    end

    # TODO: Implement following tests
    # test 'returns in' do
    #
    #
    # end
    #
    # test 'returns not in' do
    #
    #
    # end
    #
    # test 'type checking on returned objects' do
    #
    #
    # end
    #
    # test 'complex query with multiple conditions works' do
    #
    #
    # end
    #
    #
    # test 'bang method returns errors if input is bad' do
    #
    #
    # end
    #
    # test 'custom query options' do
    #
    #
    # end
    #
    # test 'more custom query options' do
    #
    #
    # end



end
