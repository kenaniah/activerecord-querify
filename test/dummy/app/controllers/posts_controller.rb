class PostsController < ApplicationController

	def index
		render json:
			Post.sortable.paginate.querify

	end


	def show
		render json:
			Post.find(params[:id]).sortable.paginate.querify
	end



end
