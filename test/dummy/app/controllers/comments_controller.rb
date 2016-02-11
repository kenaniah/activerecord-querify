class CommentsController < ApplicationController

	def index
		render json:
			Comment.sortable.paginate.querify

	end


	def show
		render json:
			Comment.where(id: params[:id]).sortable.paginate.querify
	end



end
