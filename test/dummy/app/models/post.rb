class Post < ActiveRecord::Base
	belongs_to :author, counter_cache: true
	has_many :comments, dependent: :destroy
end
