class SearchController < ApplicationController
  def search
      if params[:term].nil?
          @urls = []
      else
        @urls = Url.search params[:term]
      end
    end
end
