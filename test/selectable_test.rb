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
			@author = FactoryGirl.create(:author, name: "Test Name")
		end

		it "returns record specified by querified params" do

			Querify.params = {select: {name: "Test Name"}}

			assert_equal @author.name, "Test Name"
			assert_equal Author.selectable, @author

		end

	end

end
