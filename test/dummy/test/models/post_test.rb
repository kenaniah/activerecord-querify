require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test "post has an author" do
      FactoryGirl.create(:post)

      assert_equal Author.last, Post.last.author
  end

end
