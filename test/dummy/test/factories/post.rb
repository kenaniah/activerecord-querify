FactoryGirl.define do

	factory :post do

		transient do
			author { create(:author)}
			post { Faker::Lorem.paragraph }
			created { Faker::Date.between(24.years.ago, Date.today) }
		end

		name { post }
		author_id { author.id }
		created_at { created }

	end


end
