require 'test_helper'

class SortableIntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper

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

    test 'throws error if given column is not present' do
        get '/posts?sort[elephant]=desc'

    end


    # test 'throws exceptions if used in bang mode' do
    #     posts = Post.where(author_id: 1000000).sortable!
    #
    # end
    #
    #
	# test 'can sort by asc nulls first' do
    #
    #     Post.last.update(name: nil)
	# 	get '/posts?sort[name]=ascnf'
	# end
    #
    # test 'can sort by asc nulls last' do
    #     FactoryGirl.create(:post, name: null)
    #     get '/posts?sort[name]=ascnl'
    #
    # end
    #
    # test 'can sort by desc nulls first' do
    #     FactoryGirl.create(:post, name: null)
    #     get '/posts?sort[name]=descnf'
    #
    # end
    #
    # test 'can sort by desc nulls last' do
    #     FactoryGirl.create(:post, name: null)
    #     get '/posts?sort[nil]=descnl'
    #
    # end


# Group: Security

	# test 'cannot sort on created_at or updated_at columns' do
	# 	get '/posts?sort[updated_at]=asc'
	#
	# 	json = JSON.parse(response.body)
	#
	#
	# end

end
