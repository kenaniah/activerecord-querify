class CommentsController < ApplicationController

	def index
		render json:
			Comment.all
				
	end


	def show
		render json:
			Comment.where(id: params[:id])
	end



end
