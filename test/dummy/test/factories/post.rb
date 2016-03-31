FactoryGirl.define do

	factory :post do

		transient do
			author { create(:author)}
			post { Faker::Lorem.paragraph }
			created { Faker::Date.between(24.years.ago, Date.today) }
			updated { created + 1.day }
		end

		name { post }
		author_id { author.id }
		created_at { created }
		updated_at { updated }
	end


end
