require 'test_helper'

class QuerifyIntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper

	test 'it queries' do

		get '/posts?where[name][gt]=aaa'
		assert_equal jsonify.length, Post.where("name > ?",'aaa').length

	end

	test 'it queries again' do

		get '/posts?where[name][lt]=ZZZ'

		assert_equal jsonify.length, Post.where("name < ?",'ZZZ').paginate.length

	end






end
