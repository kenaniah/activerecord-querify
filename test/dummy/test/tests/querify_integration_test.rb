require 'test_helper'

class QuerifyIntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper

	test 'it queries' do

		get '/posts?where[name][gt]=AAA'

		assert_equal jsonify.length, Post.where("name > ?",'AAA').length

	end

	test 'it queries again' do

		get '/posts?where[name][lt]=ZZZ'

		assert_equal jsonify.length, Post.where("name < ?",'ZZZ\
		').length

	end






end
