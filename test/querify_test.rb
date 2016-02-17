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
                assert_empty Querify.where_filters
                assert_empty Querify.having_filters
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

            # it 'works with :having instead of :where in params' do
            #     Querify.params = {:having=>{"name"=>{"gteq"=>"C. Third post"}}}
            #     assert_equal 2, Post.filterable.count
            # end
            #
            # it 'ignores a group_by errors' do
            # end
            #
            # it 'performs column security if only:true' do
            # end
            #
            # it 'ignores bad operator names' do
            # end
            #
            # it 'ignores bad column names' do
            # end
            #
            # it 'ignores joins_values errors' do
            # end
            #
            # it 'returns Querify.where and Querify.having arrays with the correct results' do
            #     # how to do having here?
            #     Querify.params = {:where => {"name"=>{"lt"=>"B. Second post"}}, :having => {...}}
            #     assert_not_empty Querify.where_filters
            #     assert_not_empty Querify.having_filters
            # end

        end

        describe 'two filterable parameters' do

            # it 'returns Querify.where and Querify.having arrays with the correct results' do
            #     # how to do having here?
            #     Querify.params = {:where => {"name"=>{"gt"=>"A. First post"},"name"=>{"lt"=>"C. Third post"} }, :having => {...}}
            #     assert_not_empty Querify.where_filters
            #     assert_not_empty Querify.having_filters
            # end

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

            # it '#filterable! errors on column security error' do
            # end
            #
            # it '#filterable! errors on bad joins_values' do
            # end
            #
            # it '#filterable! errors on bad group_by' do
            # end

        end

    end
end
