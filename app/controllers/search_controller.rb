class SearchController < ApplicationController
	def search
    	if params[:term].nil?
      		@url = []
    	else
     		 @url = Url.search params[:term]
    	end
  	end
end
