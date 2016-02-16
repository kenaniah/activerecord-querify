class AuthorsController < ApplicationController

	def index
		render json:
			Author.sortable.paginate.filterable

	end


	def show
		render json:
			Author.where(id: params[:id]).sortable.paginate.filterable
	end



end
