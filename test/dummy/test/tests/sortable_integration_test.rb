require 'test_helper'

class SortableIntegrationTest < ActionDispatch::IntegrationTest
    include SortableTestHelper

	test 'sorts by ascending column name' do
		get '/posts?sort[name]=asc'

		json = JSON.parse(response.body)

		assert json[0]['name'] < json[1]['name'] && json[1]['name'] < json[2]['name']
	end

	test 'sorts by descending column name' do
		get '/posts?sort[name]=desc'

		json = JSON.parse(response.body)
		assert json[0]['name'] > json[1]['name'] && json[1]['name'] > json[2]['name']
	end

	test 'sorts on multiple columns' do
		get '/posts?sort[name]=desc&sort[id]=asc'

	end

	test 'does not produce an error for sorting on a nil column' do
		get '/posts?sort[nil]=asc'

		json = JSON.parse(response.body)
		# assert_nothing_raise(type_of_error....)
	end


# Group: Security

	# test 'cannot sort on created_at or updated_at columns' do
	# 	get '/posts?sort[updated_at]=asc'
	#
	# 	json = JSON.parse(response.body)
	# 
	#
	# end

end
