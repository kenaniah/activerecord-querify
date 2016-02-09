class PostsController < ApplicationController

	def index
		render json:
			Post.paginate

	end


	def show
		render json:
			Post.where(id: params[:id])
	end



end
