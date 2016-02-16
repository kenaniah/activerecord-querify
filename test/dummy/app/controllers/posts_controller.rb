class PostsController < ApplicationController

	def index
		render json:
			Post.sortable.paginate.filterable

	end


	def show
		render json:
			Post.find(params[:id]).sortable.paginate.filterable
	end



end
