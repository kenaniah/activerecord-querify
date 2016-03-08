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

		it "returns record specified by querified params" do

			Querify.params = {
				"select" => {
					"id" => "id",
					"name" => "Author Name",
					"posts_count" => "Number of posts"
				}
			}

			assert_equal Author.selectable, [{"id" => @author.id, "Author Name"=>"Test Author", "Number of posts" => 1}]

		end

		it 'returns record without specified id' do

			Querify.params = {
				"select" => {
					"name" => "Post Content"
				}
			}

			assert_equal Post.selectable, [{"id" => nil, "Post Content"=> @post.name}]

		end

		it 'returns nothing if column does not exist' do

			Querify.params = {
				"select" => {
					"does_not_exist" => "id"
				}
			}

			assert_equal Post.selectable, nil

		end

	end

end
