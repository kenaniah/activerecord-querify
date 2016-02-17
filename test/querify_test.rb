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
                Querify.params = {:where=>{"name"=>{"lt"=>"Z. Twenty-sixth post"}}}
                assert_equal 4, Post.filterable.count
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
                Querify.params = {:where=>{"name"=>{"is"=>"B. Second post"}}}
                assert_equal 1, Post.filterable.count
            end

            it 'returns is not' do
                Querify.params = {:where=>{"name"=>{"isnot"=>"B. Second post"}}}
                assert_equal 3, Post.filterable.count
            end

            it 'returns like' do
                Querify.params = {:where=>{"name"=>{"like"=>"b."}}}
                assert_equal 1, Post.filterable.count
            end

            # Enable when database switched to pg from sqlite3

            # it 'returns case-sensitive ilike' do
            #     FactoryGirl.create :post, name: "b. Lower-cased version of second post"
            #     Querify.params = {:where=>{"name"=>{"ilike"=>"B."}}}
            #     assert_equal 1, Post.filterable.count
            # end

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

            it 'filters with group_by' do

                # Create some posts to enhance grouping
                FactoryGirl.create(:post, author: Author.first)
                FactoryGirl.create(:post, author: Author.first)
                FactoryGirl.create(:post, author: Author.second)

                Querify.params = {:where=>{"name"=>{"isnot"=>"C. Third post"}}}

                p = Post.group(:author_id).filterable

                # p = {[author_id, number_posts], [author_id, number_posts]}
                assert_equal 3, p.count.length

                # Ensure first author has 3 posts, second has 2, last has 1
                assert_equal [3,2,1], p.count.values


            end

            it 'filters with group_by and having' do

                # Create some posts to enhance grouping
                FactoryGirl.create(:post, name: "E. Fifth post")
                FactoryGirl.create(:post, name: "F. Sixth post")
                FactoryGirl.create(:post, name: "G. Seventh post")

                Querify.params = {:where=>{"name"=>{"isnot"=>"C. Third post"}}}

                p = Post.group(:author_id).having("name > ?", "A. First post").filterable

                # p = {[author_id, number_posts], [author_id, number_posts]... }

                # There should be 5 authors returned
                assert_equal 5, p.count.length

                # Each author should have one post
                assert_equal [1,1,1,1,1], p.count.values

            end

            it 'ignores bad operator names' do
                Querify.params = {:where=>{"name"=>{"elephant"=>"123"}}}

                # Should not raise error
                Post.filterable
            end

            it 'ignores having without group_by errors' do

                Querify.params = {:where=>{"name"=>{"isnot"=>"C. Third post"}}}

                # Should not raise error
                Post.having("name > ?", "A. First post").filterable

            end

            it 'ignores bad column names' do

                Querify.params = {:where=>{"elephant"=>{"isnot"=>"C. Third post"}}}

                # Should not raise error
                Post.filterable

            end

        end

        describe 'two filterable parameters' do

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

            # it '#filterable! errors on bad joins_values' do
            # end
            #
            # it '#filterable! errors on bad group_by' do
            # end

            # Enable when switch to pg from sqlite3 

            # it '#filterable! errors on :having without :group_by' do
            #
            #     Querify.params = {:where=>{"name"=>{"isnot"=>"C. Third post"}}}
            #
            #     assert_raises.... do
            #         p = Post.having("name > ?", "A. First post").filterable!
            #     end
            #
            # end


        end

    end
end
