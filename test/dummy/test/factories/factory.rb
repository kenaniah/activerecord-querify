FactoryGirl.define do

	factory :post do
		transient do
			author { create(:author)}
			post { Faker::Lorem.paragraph }
		end

		name { post }
		author_id { author.id }
	end

	factory :author do
		transient do
			author_name { Faker::Name.name }
		end

		name { author_name }
	end

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
