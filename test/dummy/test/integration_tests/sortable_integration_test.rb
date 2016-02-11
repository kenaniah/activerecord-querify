require 'test_helper'

class SortableIntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper

    def setup
        setup_data
    end

    def teardown
        teardown_data
    end


    test 'sorts by ascending column name' do
    		get '/posts?sort[name]=asc'
    		assert jsonify[0]['name'] < jsonify[1]['name'] && jsonify[1]['name'] < jsonify[2]['name']
    	end


	test 'sorts by descending column name' do
		get '/posts?sort[name]=desc'

		assert jsonify[0]['name'] > jsonify[1]['name'] && jsonify[1]['name'] > jsonify[2]['name']
	end

	test 'sorts on multiple columns' do

        3.times do
            FactoryGirl.create(:post, name: 'a duplicate')
        end

        get '/posts?sort[name]=desc&sort[id]=desc'

        # The duplicate posts should come first in alphabetical order
        assert jsonify.first['name'] == 'a duplicate' && jsonify.first['name'] == jsonify[1]['name'] && jsonify[2]['name'] == jsonify[2]['name']

        assert jsonify.first['id'] > jsonify[1]['id'] && jsonify[1]['id'] > jsonify[2]['id']

	end

    test 'sorts correctly on column names' do
        get '/posts?sort[author_id]=desc'
        
        assert jsonify.first['author_id'] > jsonify[1]['author_id']

    end

end
