class AuthorsController < ApplicationController

	def index
		render json:
			Author.all
				
	end


	def show
		render json:
			Author.where(id: params[:id])
	end



end
