require 'test_helper'

class AuthorTest < ActiveSupport::TestCase

  test "author can create post" do
      FactoryGirl.create(:post)

      assert_not_nil Post.last.author

      assert_not_nil Author.last.posts[0]

  end

  test "author can create comment" do
      FactoryGirl.create(:comment)

      assert_not_nil Author.last

      assert_not_nil Comment.last.author

  end


end
