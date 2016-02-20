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

			Querify.params.clear
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

		end

		describe 'paginate' do

			it 'uses config for per_page settings if no option given in params' do

				Querify.params = {}

				assert_equal 3, Post.paginate.length

			end

			it 'uses options[:min_per_page] if given' do

				p = Post.paginate(min_per_page: 4)

				assert_equal 4, p.length

			end

			it 'uses config.min_per_page if no option[:min_per_page] given' do

				p = Post.paginate

				assert_equal 3, p.length

			end

			it 'uses the hardcoded 20 if no option or config min_per_page given' do

				# Create 1 more post than needed, for testing purposes
				16.times do
					FactoryGirl.create(:post)
				end

				Querify.config.per_page = nil
				Querify.config.max_per_page = 50

				p = Post.paginate
				assert_equal 20, p.length

			end

			it 'uses options[:max_per_page] if given as not nil or zero' do

				Querify.config.per_page = nil
				p = Post.paginate(max_per_page: 4)
				assert_equal 4, p.length

			end

			it 'uses config.max_per_page if no option[:max_per_page] given' do

				Querify.config.per_page = nil
				p = Post.paginate
				assert_equal 5, p.length


			end

			it 'uses the hardcoded maximum if no options provided at all' do

				Querify.config.per_page = 500
				Querify.config.max_per_page = nil

				100.times do
					FactoryGirl.create(:post)
				end

				p = Post.paginate
				assert_equal 100, p.length

			end


			it 'disables pagination and sets no headers if given params[per_page] = 0 and set :max_per_page = 0' do

				Querify.params = {:per_page => 0}

				100.times do
					FactoryGirl.create(:post)
				end

				assert Post.count > 100

				p = Post.paginate(max_per_page: nil)

				# Over the hardcoded limit
				assert p.count > 100

				assert_empty Querify.headers
			end

			it 'uses options[:page] if given' do

				a = Post.paginate(page: 1)
				b = Post.paginate(page: 2)

				assert_equal 3, a.length
				assert_equal 3, b.length

			end

			it 'uses params[:page] if given' do

				 a = Post.paginate

				 Querify.params = {:page => 2}
				 b = Post.paginate

				 assert a.length == 3 && a.length == b.length
				 assert a[0].id < b[0].id && a[1].id < b[1].id

			end

			it 'uses hardcoded page 1 if neither page options given' do

				p = Post.paginate

				assert p[0].id == Post.first.id

			end

			it 'uses params[:per_page] no matter what other option given' do

				Querify.params = {:per_page => 2}

				p = Post.paginate(per_page: 4)

				# Params should override the manually set option
				assert_equal 2, p.length

			end

			it 'uses options[:per_page] if no params[:per_page] given' do

				p = Post.paginate(per_page: 4)

				assert_equal 4, p.length

			end

			it 'uses config.per_page if no preference given in params or options hash' do

				p = Post.paginate

				assert_equal 3, p.length

			end

			it 'uses hardcoded 20 if config is not configured and no other options are given' do

				Querify.config.per_page = nil
				Querify.config.max_per_page = nil

				25.times do
					FactoryGirl.create(:post)
				end

				p = Post.paginate

				assert_equal 20, p.length

			end

			it 'does not allow per_page options greater than the max to be returned' do

				p = Post.paginate(per_page: 6)

				assert_equal 5, p.length

			end

			it 'does not allow per_page options smaller than the min to be returned' do

				Querify.config.min_per_page = 2
				p = Post.paginate(per_page: 1)

				assert_equal 2, p.length

			end

		end

		describe '#paginate?' do

			it 'determines if a query is paginated' do

				a = Post.all
				b = Post.all.paginate

				assert !a.paginated?
				assert b.paginated?

			end

		end

	end
end
