require 'test_helper'

describe ActiveRecord::Querify::Paginate do

	before do
		truncate_db
	end

	describe 'Paginate API tests' do

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

			assert_equal true, Post.paginate.paginated?
			assert_equal false, Post.paginated?

		end
	end

	describe 'pagination' do

		before do

			ActiveRecord::Querify.config.max_per_page = 5
			ActiveRecord::Querify.config.min_per_page = 1
			ActiveRecord::Querify.config.per_page = 3

			# Make one more post than the configured max_per_page for testing purposes
			6.times do
				FactoryGirl.create(:post)
			end

			ActiveRecord::Querify.params.clear

		end

		it 'only has 6 posts for testing' do
			assert_equal 6, Post.count
		end

		describe 'headers' do

			it 'returns an standard headers hash if no headers requested' do

				ActiveRecord::Querify.params = {:per_page=>3}
				Post.paginate
				assert_equal 2, ActiveRecord::Querify.headers.length

			end

			it 'returns a complete headers hash if requested' do

				ActiveRecord::Querify.params = {:page_total_stats=>"on"}
				Post.paginate
				assert_equal 4, ActiveRecord::Querify.headers.length

			end

		end

		describe '#paginate' do

			it 'uses config for per_page settings if no option given in params' do

				ActiveRecord::Querify.params = {}

				assert_equal 3, Post.paginate.length

			end

			it 'returns only record that is within the params of since_date range' do
				ActiveRecord::Querify.params = {:since_date => '1991-09-12'}

				p = Post.paginate

				assert_includes(Date.parse('1991-09-12')..Time.now, p.all.sample.created_at)
				refute_includes(Date.parse('1900-01-01')..Date.parse('1991-09-11'), p.all.sample.created_at)
			end


			it 'returns only record that is within the params of until_date range' do
				ActiveRecord::Querify.params = {:until_date => '2015-09-12'}

				p = Post.paginate

				assert_includes(Date.parse("1900-1-1")..Date.parse('2015-09-12'), p.all.sample.created_at)
				refute_includes(Date.parse("2015-09-13")..Time.now, p.all.sample.created_at)
			end

			it 'returns only record that is within the params of since_date and until_date' do
				ActiveRecord::Querify.params = {:since_date => '1991-09-12', :until_date => '2015-09-12'}

				p = Post.paginate

				assert_includes(Date.parse("1991-09-12")..Date.parse("2015-09-12"), p.all.sample.created_at)
				refute_includes(Date.parse("1900-1-1")..Date.parse("1991-09-11"), p.all.sample.created_at)
				refute_includes(Date.parse("2015-09-12")..Time.now, p.all.sample.created_at)
			end

			it 'uses default created_at, since_date and until_date if no params given' do
				ActiveRecord::Querify.params = {}

				p = Post.paginate

				assert_includes(Date.parse("1900-1-1")..Time.now, p.all.sample.created_at)
			end

			it 'returns only record that is within the params of since_date range for updated_at' do
				ActiveRecord::Querify.params = {:column => "updated_at", :since_date => '1991-09-12'}

				p = Post.paginate

				assert_includes(Date.parse('1991-09-12')..Time.now, p.all.sample.updated_at)
				refute_includes(Date.parse('1900-01-01')..Date.parse('1991-09-11'), p.all.sample.updated_at)
			end

			it 'returns only record that is within the params of until_date range for updated_at' do
				ActiveRecord::Querify.params = {:column => "updated_at", :until_date => '2015-09-12'}

				p = Post.paginate

				assert_includes(Date.parse("1900-1-1")..Date.parse('2015-09-12'), p.all.sample.updated_at)
				refute_includes(Date.parse("2015-09-13")..Time.now, p.all.sample.updated_at)
			end


			it 'returns only record that is within the params of since_date and until_date for updated_at' do
				ActiveRecord::Querify.params = {:column => "updated_at", :since_date => '1991-09-12', :until_date => '2015-09-12'}

				p = Post.paginate

				assert_includes(Date.parse("1991-09-12")..Date.parse("2015-09-12"), p.all.sample.updated_at)
				refute_includes(Date.parse("1900-1-1")..Date.parse("1991-09-11"), p.all.sample.updated_at)
				refute_includes(Date.parse("2015-09-12")..Time.now, p.all.sample.updated_at)
			end

			it 'will return default since_date if params of since_date is invalid' do
				ActiveRecord::Querify.params = {:since_date => 'foo'}

				p = Post.paginate

				assert_includes(Date.parse("1991-09-12")..Time.now, p.all.sample.created_at)
			end

			it 'will return default until_date if params of until_date is invalid' do
				ActiveRecord::Querify.params = {:until_date => 'bar'}

				p = Post.paginate

				assert_includes(Date.parse("1900-1-1")..Time.now, p.all.sample.created_at)
			end

			it 'will return default created_at if params of column is invalid' do
				ActiveRecord::Querify.params = {:column => 'jefferson'}

				p = Post.paginate

				assert_includes(Date.parse("1900-1-1")..Time.now, p.all.sample.created_at)
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

				ActiveRecord::Querify.config.per_page = nil
				ActiveRecord::Querify.config.max_per_page = 50

				p = Post.paginate
				assert_equal 20, p.length

			end

			it 'uses options[:max_per_page] if given as not nil or zero' do

				ActiveRecord::Querify.config.per_page = nil
				p = Post.paginate(max_per_page: 4)
				assert_equal 4, p.length

			end

			it 'uses config.max_per_page if no option[:max_per_page] given' do

				ActiveRecord::Querify.config.per_page = nil
				p = Post.paginate
				assert_equal 5, p.length

			end

			it 'uses the hardcoded maximum if no options provided at all' do

				ActiveRecord::Querify.config.per_page = 500
				ActiveRecord::Querify.config.max_per_page = nil

				100.times do
					FactoryGirl.create(:post)
				end

				p = Post.paginate
				assert_equal 100, p.length

			end


			it 'disables pagination and sets no headers if given params[per_page] = 0 and set :max_per_page = 0' do

				ActiveRecord::Querify.params = {:per_page => 0}

				100.times do
					FactoryGirl.create(:post)
				end

				assert Post.count > 100

				p = Post.paginate(max_per_page: nil)

				# Over the hardcoded limit
				assert p.count > 100

				assert_empty ActiveRecord::Querify.headers

			end

			it 'uses options[:page] if given' do

				a = Post.paginate(page: 1)
				b = Post.paginate(page: 2)

				assert_equal 3, a.length
				assert_equal 3, b.length

			end

			it 'uses params[:page] if given' do

				 a = Post.paginate

				 ActiveRecord::Querify.params = {:page => 2}
				 b = Post.paginate
				 assert a.length == 3 && a.length == b.length
				 assert a[0].id < b[0].id && a[1].id < b[1].id

			end

			it 'uses hardcoded page 1 if neither page options given' do

				p = Post.paginate

				assert_equal p.first.id, Post.first.id

			end

			it 'uses params[:per_page] no matter what other option given' do

				ActiveRecord::Querify.params = {:per_page => 2}

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

				ActiveRecord::Querify.config.per_page = nil
				ActiveRecord::Querify.config.max_per_page = nil

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

				ActiveRecord::Querify.config.min_per_page = 2
				p = Post.paginate(per_page: 1)

				assert_equal 2, p.length

			end

			describe "issue #27" do

				before do
					ActiveRecord::Querify.params = {:page_total_stats => 1}
				end

				it 'should return a proper count for simple queries' do
					Post.paginate
					assert_equal Post.count, ActiveRecord::Querify.headers["X-Total-Results"].to_i
				end

				it 'should return a proper count for queries using #group' do
					p1 = Post.first
					p2 = Post.second
					2.times do
						FactoryGirl.create :comment, post: p1
					end
					3.times do
						FactoryGirl.create :comment, post: p2
					end
					Comment.select("post_id").group("post_id").paginate
					assert_equal 2, ActiveRecord::Querify.headers["X-Total-Results"].to_i
				end

				it 'should return a proper count for queries using #select' do
					Post.select("posts.*", "posts.id").paginate
					assert_equal Post.count, ActiveRecord::Querify.headers["X-Total-Results"].to_i
				end

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
