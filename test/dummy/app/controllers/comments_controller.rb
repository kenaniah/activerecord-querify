class CommentsController < ApplicationController

	def index
		render json:
			Comment.sortable.paginate.filterable

	end


	def show
		render json:
			Comment.where(id: params[:id]).sortable.paginate.filterable
	end



end
