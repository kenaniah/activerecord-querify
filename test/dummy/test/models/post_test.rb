class PostTest < ActiveSupport::TestCase

  test "post has an author" do

      post = FactoryGirl.create(:post)

      assert_not_nil post.author

  end

end
