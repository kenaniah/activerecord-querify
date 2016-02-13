require 'test_helper'

class AuthorTest < ActiveSupport::TestCase

    def setup
        @author = FactoryGirl.create(:author)
    end

    def teardown
        @author = nil
    end

    test "author can create post" do
        FactoryGirl.create(:post, author: @author)

        assert_not_empty @author.posts
    end

    test "author can create comment" do
        post = FactoryGirl.create(:post, author: @author)
        FactoryGirl.create(:comment, post: post)

        assert_not_empty post.comments
        assert_not_nil post.comments.first.author
    end
end
