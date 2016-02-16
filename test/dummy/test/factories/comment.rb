FactoryGirl.define do

	factory :comment do
		
		transient do
			post {Post.all.sample || create(:post)}
			another_author { create(:author)}
			comment_body { Faker::Lorem.sentence }
		end

		post_id { post.id }
		author_id { another_author.id }
		comment { comment_body }

	end

end
