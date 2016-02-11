FactoryGirl.define do
	factory :post do
		transient do
			author { create(:author)}
			post { "Post " +  Random.rand(1..10000).to_s }
		end

		name { post }
		author_id { author.id }
	end

	factory :author do
		transient do
			author_name { "Author " + Random.rand(1..10000).to_s }
		end

		name { author_name }
	end

	factory :comment do
		transient do
			post { Post.last || create(:post)}
			another_author { create(:author)}
			comment_body { "Comment " + Random.rand(1..10000).to_s }
		end

		post_id { post.id }
		author_id { another_author.id }
		comment { comment_body }

	end
end
