require 'test_helper'

describe Querify::Paginate do

	before do
		truncate_db
	end

	describe 'Paginate sanity tests' do

		it 'ActiveRecord responds to #paginate' do
			FactoryGirl.create(:post)
			assert_respond_to Post, :paginate
			assert_respond_to Post.all, :paginate
			assert_respond_to Post.first.comments, :paginate
		end

		it 'ActiveRecord responds to #paginated?' do
			FactoryGirl.create(:post)
			assert_respond_to Post, :paginated?
			assert_respond_to Post.all, :paginated?
			assert_respond_to Post.first.comments, :paginated?
		end

		it 'ActiveRecord knows if the query is paginated' do
			assert Post.paginate.paginated?
			assert_equal false, Post.paginated?
		end
	end

	describe 'pagination' do

		before do

			Querify.config.max_per_page = 5
			Querify.config.min_per_page = 1
			Querify.config.per_page = 3

			# Make one more post than the configured max_per_page for testing purposes
			6.times do
				FactoryGirl.create(:post)
			end
		end

		it 'only has 6 posts for testing' do
			assert_equal 6, Post.count
		end

		describe 'headers' do

			it 'returns an standard headers hash if no headers requested' do

				Querify.params = {:per_page=>3}
				Post.paginate
				assert_equal 2, Querify.headers.length

			end

			it 'returns a complete headers hash if requested' do

				Querify.params = {:page_total_stats=>"on"}
				Post.paginate
				assert_equal 4, Querify.headers.length

			end

			it 'returns an empty headers hash if no pagination is performed' do
				Querify.params = {:per_page => 0, :max_per_page => nil}

				# Post.all.paginate
				# assert_equal 0, Querify.headers.length
			end
		end

		describe 'paginate' do

			it 'uses config for per_page settings if no option given in params' do
				Querify.params = {}
				assert_equal 3, Post.paginate.length

			end

			it 'returns the per_page number given in params if it falls between configured max and min' do

				Querify.params = {:per_page=>2}

				assert_equal 2, Post.paginate.length

			end

			it 'does not allow more results than the configured max_per_page' do

				Querify.params = {:per_page=>6}

				assert_equal 5, Post.paginate.length

				# Querify.params = {:max_per_page=>6}
				#
				# assert_equal 5, Post.paginate.length

			end

			it 'returns the default per_page if per_page is set to nil in params' do

				Querify.params = {:per_page=>nil}

				assert_equal 3, Post.paginate.length

			end

			# it 'uses the configured per_page if max_per_page option is negative' do
			#
			# 	Querify.config.max_per_page = -1
			#
			# 	assert_equal 3, Post.paginate.length
			#
			# end

			# it 'uses configured per_page if min_per_page option is negative' do
			#
			# 	Querify.config.min_per_page = -1
			#
			# 	assert_equal 3, Post.paginate.length
			#
			# end

		end

		describe '#paginate?' do

			it 'determines if a query is paginated' do

				a = Post.all
				b = Post.all.paginate

				# # This should disable pagination
				# Querify.config.max_per_page = nil
				# Querify.params = {:per_page => 0, :max_per_page => 0}
				# c = Post.all.paginate

				assert !a.paginated?
				assert b.paginated?
				# assert !c.paginated?

			end

		end

	end
end
