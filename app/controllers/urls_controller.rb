class UrlsController < ApplicationController
  require 'rubygems'
  require 'normalize_url'
  require 'domainatrix'
  skip_before_action :verify_authenticity_token
  
  def index
  end

  def new
    flash[:notice]=""
    @url=Url.new 
  end

  def get_short_url
    @url=Url.new
    @url.long_url = NormalizeUrl.process(params[:url][:long_url])
    @url.domain = (Domainatrix.parse(@url.long_url)).domain
    @url_find = Rails.cache.fetch("#{@url.long_url}" , expires_in: 15.minutes) do 
      Url.find_by :domain => @url.domain, :long_url => @url.long_url
    end
    if @url_find.blank?
      @url.short_url = Url.shorten_url(@url.long_url)
    else
      @url = @url_find
    end
    respond_to do |format|
      if @url.short_url == "invalid url"
        @url=Url.new
        flash[:notice] = 'Invalid Url' 
        format.html{render :new }
        format.json {render json: {"long url:" => "Invalid input"}}
      else
        @url = Rails.cache.fetch("#{@url.long_url}")
        format.html { redirect_to(@url)  }
        format.json{render json: {"short url" => @url.short_url}}
      end
    end
  end

  def show
    @url = Url.find_by(id: params[:id])
  end

  def short_to_long_url
    flash[:notice]=""
    @url=Url.new
  end


  def get_long_url
    @url=Url.new
    @url.short_url = params[:urls][:short_url]
    @url_find = Rails.cache.fetch("#{@url.short_url}" , expires_in: 15.minutes) do
      Url.find_by :short_url => @url.short_url
    end
    @url.long_url = @url_find.nil? ? "Not found" : @url_find.long_url
    respond_to do |format|
      if @url.long_url == "Not found"
        @url=Url.new
        flash[:error] = 'Doesn\'t exist in database'
        format.html{render :short_to_long_url}
        format.json {render json: {"short url:" => "No long url for this"}}
      else
        format.html{render :show_long_url}
        format.json {render json: {"long url" => @url_find.long_url}}
      end
    end
  end
end
