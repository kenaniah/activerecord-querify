require 'test_helper'

describe Querify::Selectable do

	before do
		truncate_db
	end

	describe "ActiveRecord respond to selectable" do
		it 'responds to selectable' do
			FactoryGirl.create(:author)

			assert_respond_to Author, :selectable
			assert_respond_to Author.all, :selectable
			assert_respond_to Author.first.comments, :selectable
		end
	end

	describe "Selectable" do

		before do
			@author = FactoryGirl.create(:author, name: "Test Author")
			@post = FactoryGirl.create(:post, author: @author)
		end

		it 'returns nothing if select params is not given' do

			Querify.params = {}

			assert_equal Author.selectable, nil

		end

		it "returns record specified by select params" do

			Querify.params = {
				"select" => {
					"name" => "Author Name",
					"posts_count" => "Number of posts"
				}
			}

			assert_equal Author.selectable, [{"id"=> @author.id, "Author Name"=>"Test Author", "Number of posts" => 1}]

		end

		it 'returns nothing if column does not exist' do

			Querify.params = {
				"select" => {
					"does_not_exist" => "id"
				}
			}

			assert_equal Post.selectable, nil

		end

		it 'returns nothing if trying to alias id' do

			Querify.params = {
				"select" => {
					"id" => "Post Id"
				}
			}

			assert_equal Post.selectable, nil

		end

		it 'returns multiple records' do

			@post2 = FactoryGirl.create(:post)

			Querify.params = {
				"select" => {
					"name" => "Post Content"
				}
			}

			assert_equal Post.selectable, [{"id" => @post.id, "Post Content" => @post.name}, {"id" => @post2.id, "Post Content" => @post2.name}]

		end

		it 'returns AR relationships' do

			Querify.params = {
				"select" => {
					"name" => "Post Content"
				}
			}

			assert_equal @author.posts.count, 1
			assert_equal @author.posts.selectable, [{"id" => @post.id, "Post Content" => @post.name}]

		end

		it 'returns AR relationships with multiple select query' do

			Querify.params = {
				"select" => {
					"name" => "Post Content",
					"created_at" => "Time of Creation"
				}
			}

			assert_equal @author.posts.count, 1
			assert_equal @author.posts.selectable, [{"id" => @post.id, "Post Content" => @post.name, "Time of Creation" => @post.created_at}]

		end

	end

	describe "Selectable!" do

		before do
			@author = FactoryGirl.create(:author, name: "Test Author")
			@post = FactoryGirl.create(:post, author: @author)
		end

		it 'raises Querify::ParameterNotGiven if select params is not given' do

			Querify.params = {}

			assert_raises Querify::ParameterNotGiven do
				Author.selectable!
			end

		end

		it "returns record specified by select params" do

			Querify.params = {
				"select" => {
					"name" => "Author Name",
					"posts_count" => "Number of posts"
				}
			}

			assert_equal Author.selectable!, [{"id"=> @author.id, "Author Name"=>"Test Author", "Number of posts" => 1}]

		end

		it 'raise Querify::InvalidColumn error if column does not exist' do

			Querify.params = {
				"select" => {
					"does_not_exist" => "id"
				}
			}

			assert_raises Querify::InvalidColumn do
				Author.selectable!
			end

		end

		it 'raises Qerify::InvalidColumn error if trying to alias id' do

			Querify.params = {
				"select" => {
					"id" => "Post Id"
				}
			}

			assert_raises Querify::InvalidColumn do
				Author.selectable!
			end

		end

		it 'returns multiple records' do

			@post2 = FactoryGirl.create(:post)

			Querify.params = {
				"select" => {
					"name" => "Post Content"
				}
			}

			assert_equal Post.selectable!, [{"id" => @post.id, "Post Content" => @post.name}, {"id" => @post2.id, "Post Content" => @post2.name}]

		end

		it 'returns AR relationships' do

			Querify.params = {
				"select" => {
					"name" => "Post Content"
				}
			}

			assert_equal @author.posts.count, 1
			assert_equal @author.posts.selectable!, [{"id" => @post.id, "Post Content" => @post.name}]

		end

		it 'returns AR relationships with multiple select query' do

			Querify.params = {
				"select" => {
					"name" => "Post Content",
					"created_at" => "Time of Creation"
				}
			}

			assert_equal @author.posts.count, 1
			assert_equal @author.posts.selectable!, [{"id" => @post.id, "Post Content" => @post.name, "Time of Creation" => @post.created_at}]

		end

	end

end
