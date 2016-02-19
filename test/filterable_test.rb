require 'test_helper'

describe Querify do

    before do
        truncate_db
    end

    describe 'Filterable sanity tests' do

        it 'is a module' do
            assert_kind_of Module, Querify
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

    describe 'filtering' do

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

            Querify.params.clear
        end

        it 'only has 4 posts for testing' do
            assert_equal 4, Post.count
        end

        describe 'no filterable parameters' do

            it 'returns empty Querify.where and Querify.having arrays' do
                Querify.params = {:where => {}}
                Post.filterable
                assert_equal [], Querify.where_filters
                assert_equal [], Querify.having_filters
            end

        end

        describe 'one filterable parameter' do

            it 'returns greater than' do
                Querify.params = {:where=>{"name"=>{"lt"=>"D. Fourth post"}}}
                assert_equal 3, Post.filterable.count
            end

            it 'returns greater than or equal to' do
                Querify.params = {:where=>{"name"=>{"gteq"=>"C. Third post"}}}
                assert_equal 2, Post.filterable.count
            end

            it 'returns less than' do
                Querify.params = {:where=>{"name"=>{"lt"=>"B. Second post"}}}
                assert_equal 1, Post.filterable.count
            end

            it 'returns less than or equal to' do
                Querify.params = {:where=>{"name"=>{"lteq"=>"B. Second post"}}}
                assert_equal 2, Post.filterable.count
            end

            it 'returns equal to' do
                Querify.params = {:where=>{"name"=>{"eq"=>"B. Second post"}}}
                assert_equal 1, Post.filterable.count
            end

            it 'returns not equal to' do
                Querify.params = {:where=>{"name"=>{"neq"=>"B. Second post"}}}
                assert_equal 3, Post.filterable.count
            end

            it 'returns is' do
                FactoryGirl.create(:post, name: nil)
                Querify.params = {:where=>{"name"=>{"is"=>':null'}}}
                assert_equal 1, Post.filterable.count
            end

            it 'returns is not' do
                FactoryGirl.create(:post, name: nil)
                Querify.params = {:where=>{"name"=>{"isnot"=>':null'}}}
                assert_equal 4, Post.filterable.count
            end

            it 'returns case insensitive like' do
                Querify.params = {:where=>{"name"=>{"ilike"=>"b."}}}
                assert_equal 1, Post.filterable.count
            end

            it 'returns case sensitive like' do
                Querify.params = {:where=>{"name"=>{"like"=>"b."}}}
                assert_equal 0, Post.filterable.count
            end

            it 'returns in' do
                Querify.params = {:where=>{"name"=>{"in"=>"A. First post,B. Second post"}}}
                assert_equal 2, Post.filterable.count
            end

            it 'returns not in' do
                Querify.params = {:where=>{"name"=>{"notin"=>"A. First post,B. Second post"}}}
                assert_equal 2, Post.filterable.count
            end

            it 'ignores errors on column security violations' do
                Post.filterable(columns: {author_id: :integer}, only: true)
                Querify.params = {:where=>{"id"=>{"notin"=>"A. First post,B. Second post"}}}

                # No error should be raised because #filterable ignores errors
                p = Post.all.filterable

                # Result should not conform to the banned params
                assert_equal 4, p.length

            end


            # TODO: Fix this test

            it 'filters using joins' do

                FactoryGirl.create(:comment, post: Post.last, author: Author.first)

                Querify.params = {where:{":comments.id"=>{"neq"=>1}}}
                p = Post.joins(:comments).filterable
                assert_equal 3, p.length
            end

            it 'filters with group_by' do

                # Create some posts to enhance grouping
                FactoryGirl.create(:post, author: Author.first)
                FactoryGirl.create(:post, author: Author.first)
                FactoryGirl.create(:post, author: Author.second)

                Querify.params = {:where=>{"name"=>{"neq"=>"C. Third post"}}}

                # p = {[author_id, number_posts], [author_id, number_posts]}
                p = Post.group(:author_id).filterable

                assert_equal 3, p.count.length

                # Ensure an author with 3 posts, an author with 2 posts, and an author with 1 post
                assert p.count.values.include?(1) && p.count.values.include?(2) && p.count.values.include?(3)

            end

            it 'filters with :group_by and :having' do

                FactoryGirl.create(:post, author: Author.second, name: "A. First post")
                FactoryGirl.create(:post, author: Author.second, name: "B. Second post")

                Querify.params = {:where=>{"name"=>{"neq"=>"C. Third post"}}, :having=>{"author_id"=>{"lt"=>1}}}

                p = Post.group(:author_id).filterable

                # There should be no authors returned
                assert_equal 0, p.count.length

            end

            it 'ignores bad operator names' do

                Querify.params = {:where=>{"name"=>{"elephant"=>"123"}}}

                # Should not raise error
                Post.filterable

            end

            it 'ignores having without group_by errors' do

                Querify.params = {:having=>{"name"=>{"neq"=>"C. Third post"}}}

                # Should not raise error
                Post.filterable

            end

            it 'ignores bad column names' do

                Querify.params = {:where=>{"elephant"=>{"neq"=>"C. Third post"}}}

                # Should not raise error
                Post.filterable

            end

            it 'can use filterable, sortable, and paginate all at once' do

                Querify.config.min_per_page = 1
                Querify.params = {:where=>{"name"=>{"neq"=>"C. Third post"}}, :sort=>{"name" => :asc}, :per_page=>2}
                p = Post.sortable.filterable.paginate

                assert_equal 2, p.length
                assert p[0].name < p[1].name
                assert p[0].name != "C. Third post" && p[1].name != "C. Third post"

            end

        end

        describe 'two filterable parameters' do

            it 'works with two filterable parameters' do

                Querify.params = {:where=>{"name"=>{"neq"=>"C. Third post"},"comments_count"=>{"gt"=>0}}}
                p = Post.filterable
                assert_equal 2, p.length

            end

        end


        describe '#filterable!' do

            it '#filterable! errors on bad operator' do

                Querify.params = {:where=>{"name"=>{"asdf"=>"B."}}}
                assert_raises Querify::InvalidOperator do
    				Post.filterable!.to_a

    			end
            end

            it '#filterable! errors on bad column name' do

                Querify.params = {:where=>{"asdf"=>{"gt"=>"B."}}}
                assert_raises Querify::InvalidFilterColumn do
    				Post.filterable!.to_a

    			end
            end

            it '#filterable! errors on column security error' do

                one_id = Post.second.id
                another_id = Post.last.id

                Querify.params = {:where=>{"id"=>{"notin"=>"#{one_id},#{another_id}"}}}
                assert_raises Querify::InvalidFilterColumn do
                    Post.all.filterable!(columns: {author_id: :integer}, only: true)

                end

            end

            it '#filterable! errors on :having without :group_by' do

                Querify.params = {:having=>{"name"=>{"neq"=>"C. Third post"}}}
                puts "Having without grouped by"

                assert_raises Querify::QueryNotYetGrouped do
                    Post.having("author_id > ?", "1").filterable!
                end

            end


        end

    end


end
