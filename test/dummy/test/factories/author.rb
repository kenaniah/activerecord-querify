FactoryGirl.define do

	factory :author do

		transient do
			author_name { Faker::Name.name }
		end

		name { author_name }
		
	end

end
