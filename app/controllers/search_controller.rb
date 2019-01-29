class SearchController < ApplicationController
  
  def search
  end

  def search_result
    if params[:term].nil?
        @urls = []
      else
        @urls = Url.search params[:term]
    end
  end
end
