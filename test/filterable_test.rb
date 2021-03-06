require 'test_helper'

describe ActiveRecord::Querify do

	before do
		truncate_db
	end

	describe 'Filterable API tests' do

		it 'is a module' do
			assert_kind_of Module, ActiveRecord::Querify
		end

		it 'has access to the test dummy model' do
			assert Post
		end

		it 'can be called on AR models' do
			assert_respond_to Post, :filterable
		end

		it 'can be called on AR relations' do
			FactoryGirl.create :post
			assert_respond_to Post.first.comments, :filterable
		end

		it 'can be called on AR collection proxies' do
			assert_respond_to Post.all, :filterable
		end
	end


	# Set up before tests for filterable

	describe 'Filterable and Filterable!' do

		before do

			@one = FactoryGirl.create :post, name: "A. First post"
			@two = FactoryGirl.create :post, name: "B. Second post"
			@three = FactoryGirl.create :post, name: "C. Third post"
			@four = FactoryGirl.create :post, name: "D. Fourth post"

			# Additional comments for multi-sorting
			FactoryGirl.create :comment, post: @one
			FactoryGirl.create :comment, post: @two

			@ascending = [@one, @four, @two, @three]
			@descending = [@three, @two, @four, @one]

			ActiveRecord::Querify.params.clear

		end

		it 'only has 4 posts for testing' do

			assert_equal 4, Post.count

		end

		describe '#Filterable' do

			it 'returns empty Querify.where and Querify.having arrays' do

				ActiveRecord::Querify.params = {where: {}}
				Post.filterable

				assert_equal [], ActiveRecord::Querify.where_filters
				assert_equal [], ActiveRecord::Querify.having_filters

			end

			it 'does not filter on empty values' do

				ActiveRecord::Querify.params = {where: {"id" => {":eq" => ""}}}
				p = Post.all.filterable
				assert_equal [], ActiveRecord::Querify.where_filters
				assert_equal 4, p.length

			end

			it 'ignores errors on column security violations' do

				Post.filterable(columns: {author_id: :integer}, only: true)
				ActiveRecord::Querify.params = {where: {"id" => {"notin" => "A. First post,B. Second post"}}}

				# No error should be raised because #filterable ignores errors
				p = Post.all.filterable

				# Result should not conform to the banned params
				assert_equal 4, p.length

			end

			it 'ignores bad operator names' do

				ActiveRecord::Querify.params = {where: {"name" => {"elephant" => "123"}}}

				# Should not raise error
				Post.filterable

			end

			it 'ignores having without group_by errors' do

				ActiveRecord::Querify.params = {having: {"name" => {"neq" => "C. Third post"}}}

				# Should not raise error
				Post.filterable

			end

			it 'ignores bad column names' do

				ActiveRecord::Querify.params = {where: {"elephant" => {"neq" => "C. Third post"}}}

				# Should not raise error
				Post.filterable

			end
		end

		describe '#Filterable!' do

			it '#filterable! errors on bad operator' do

				ActiveRecord::Querify.params = {where: {"name" => {"asdf" => "B."}}}
				assert_raises ActiveRecord::Querify::InvalidOperator do
					Post.filterable!.to_a

				end
			end

			it '#filterable! errors on bad column name' do

				ActiveRecord::Querify.params = {where: {"asdf" => {"gt" => "B."}}}
				assert_raises ActiveRecord::Querify::InvalidFilterColumn do
					Post.filterable!.to_a

				end
			end

			it '#filterable! errors on column security error' do

				one_id = Post.second.id
				another_id = Post.last.id

				ActiveRecord::Querify.params = {where: {"id" => {"notin" => "#{one_id},#{another_id}"}}}
				assert_raises ActiveRecord::Querify::InvalidFilterColumn do
					Post.all.filterable!(columns: {author_id: :integer}, only: true)

				end

			end

			it '#filterable! errors on :having without :group_by' do

				ActiveRecord::Querify.params = {having: {"name" => {"neq" => "C. Third post"}}}

				assert_raises ActiveRecord::Querify::QueryNotYetGrouped do
					Post.having("author_id > ?", "1").filterable!
				end

			end

			describe 'one filterable parameter' do

				it 'returns greater than' do

					ActiveRecord::Querify.params = {where: {"name"=>{"lt"=>"D. Fourth post"}}}

					assert_equal 3, Post.filterable!.count

				end

				it 'returns greater than or equal to' do

					ActiveRecord::Querify.params = {where: {"name"=>{"gteq"=>"C. Third post"}}}

					assert_equal 2, Post.filterable!.count

				end

				it 'returns less than' do

					ActiveRecord::Querify.params = {where: {"name"=>{"lt"=>"B. Second post"}}}

					assert_equal 1, Post.filterable!.count

				end

				it 'returns less than or equal to' do

					ActiveRecord::Querify.params = {where: {"name"=>{"lteq" => "B. Second post"}}}

					assert_equal 2, Post.filterable!.count

				end

				it 'returns equal to' do

					ActiveRecord::Querify.params = {where: {"name"=>{"eq"=>"B. Second post"}}}
					assert_equal 1, Post.filterable!.count

				end

				it 'returns not equal to' do

					ActiveRecord::Querify.params = {where: {"name"=>{"neq"=>"B. Second post"}}}

					assert_equal 3, Post.filterable!.count

				end

				it 'returns is' do

					FactoryGirl.create(:post, name: nil)
					ActiveRecord::Querify.params = {where: {"name"=>{"is"=>':null'}}}

					assert_equal 1, Post.filterable!.count

				end

				it 'returns is not' do

					FactoryGirl.create(:post, name: nil)
					ActiveRecord::Querify.params = {where: {"name" => {"isnot" => ':null'}}}

					assert_equal 4, Post.filterable!.count

				end

				it 'returns case insensitive like' do

					ActiveRecord::Querify.params = {where: {"name" => {"ilike" => "b."}}}

					assert_equal 1, Post.filterable!.count

				end

				it 'returns case sensitive like' do

					ActiveRecord::Querify.params = {where: {"name" => {"like" => "b."}}}

					assert_equal 0, Post.filterable!.count

				end

				it 'returns in' do

					ActiveRecord::Querify.params = {where: {"name" => {"in" => "A. First post,B. Second post"}}}

					assert_equal 2, Post.filterable!.count

				end

				it 'returns not in' do

					ActiveRecord::Querify.params = {where: {"name" => {"notin" => "A. First post,B. Second post"}}}

					assert_equal 2, Post.filterable!.count

				end

				it 'filters using joins' do

					FactoryGirl.create(:comment, post: Post.last, author: Author.first, comment: "some comment")

					ActiveRecord::Querify.params = {where: {"comments.comment" => {"eq" => "some comment"}}}
					p = Post.joins(:comments).filterable!

					assert_equal 1, p.length
				end

				it 'filters with group_by' do

					ActiveRecord::Querify.params = {where: {"name" => {"neq" => "C. Third post"}}}

					# p = {[author_id, number_posts], [author_id, number_posts]}
					p = Post.group(:author_id).filterable!

					assert_equal 3, p.count.length

					assert p.count.values.include?(1)

				end

				it 'filters with :group_by and :having' do

					ActiveRecord::Querify.params = {where: {"name" => {"neq" => "C. Third post"}}, having: {"author_id" => {"lt" => 1}}}

					p = Post.group(:author_id).filterable!

					# There should be no authors returned
					assert_equal 0, p.count.length

				end

				it 'can use filterable!, sortable, and paginate all at once' do

					ActiveRecord::Querify.config.min_per_page = 1
					ActiveRecord::Querify.params = {where: {"name" => {"neq" => "C. Third post"}}, sort: {"name"  =>  :asc}, :per_page => 2}
					p = Post.sortable.filterable!.paginate

					assert_equal 2, p.length
					assert p[0].name < p[1].name
					assert p[0].name != "C. Third post" && p[1].name != "C. Third post"

				end

			end

			describe 'two filterable! parameters' do

				it 'works with two filterable! parameters' do

					ActiveRecord::Querify.params = {where: {"name" => {"neq" => "C. Third post"},"comments_count" => {"gt" => 0}}}
					p = Post.filterable!
					assert_equal 2, p.length

				end

			end

		end

	end

end
