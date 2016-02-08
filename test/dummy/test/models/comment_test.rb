require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "comment is associated with a post" do
      FactoryGirl.create(:comment)

      assert_not_nil Post.last.comments[0]

  end

end
