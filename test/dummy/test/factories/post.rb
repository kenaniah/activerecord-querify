FactoryGirl.define do

	factory :post do

		transient do
			author { create(:author)}
			post { Faker::Lorem.paragraph }
		end

		name { post }
		author_id { author.id }

	end
	
end
