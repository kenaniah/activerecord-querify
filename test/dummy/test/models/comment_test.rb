require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "comment is associated with a post" do

      comment = FactoryGirl.create(:comment)

      assert_not_nil comment.post

  end

end
