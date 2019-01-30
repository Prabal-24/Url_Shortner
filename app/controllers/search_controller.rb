class SearchController < ApplicationController
  
  def search
  end
  
  def search_result
    if params[:term].nil?
        @urls = []
      else
        @urls = Url.custom_search(params)
    end
  end
end
