class AuthorsController < ApplicationController

	def index
		render json:
			Author.sortable.paginate.querify

	end


	def show
		render json:
			Author.where(id: params[:id]).sortable.paginate.querify
	end



end
