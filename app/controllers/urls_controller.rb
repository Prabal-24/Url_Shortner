class UrlsController < ApplicationController
  require 'rubygems'
  require 'normalize_url'
  require 'domainatrix'
  skip_before_action :verify_authenticity_token
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** GET <br/>
  **Route :**/urls <br/>
  
=end  
  def index
  end
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** GET <br/>
  **Route :**/urls/new <br/>

=end 
  def new
    flash[:notice]=""
    @url=Url.new 
  end
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** POST <br/>
  **Route :**/get_short_url <br/>
  **Request Format:** {long-url - String} <br/>
  **Response Format:** Success(status : 200) {"short-url" => "String"}
                       Invalid(status : 404) {"long url:" => "Invalid input"}
=end 
  def get_short_url
    @url = Url.new(url_params)
    if @url.valid?
      @url.long_url = NormalizeUrl.process(params[:url][:long_url])
      @url.domain = (Domainatrix.parse(@url.long_url)).domain
      @url_find = Url.find_by :domain => @url.domain, :long_url => @url.long_url
      @url = @url_find.blank? ? Url.shorten_url(@url.long_url) : @url_find
    end
    respond_to do |format|
      if @url.errors[:long_url].include?("is invalid")
        @url=Url.new
        flash[:danger] = 'Invalid Url' 
        format.html{render :new ,:status=>404}
        format.json {render json: {"long url:" => "Invalid input"}}
      else
        format.html { redirect_to(@url)  }
        format.json{render json: {"short url" => @url.short_url}}
      end
    end
  end
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** GET <br/>
  **Route :**/urls/:id<br/>
=end 
  def show
    @url = Url.find_by(id: params[:id])
  end
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** GET <br/>
  **Route :**/urls/short_to_long_url<br/>
=end 
  def short_to_long_url
    flash[:notice]=""
    @url=Url.new
  end
=begin
  **Author:** Prabal Partap <br/>
  **Request Type:** GET <br/>
  **Route :** /get_long_url <br/>
  **Request Format:** {short-url - String} <br/>
  **Response Format:** Success(status : 200) {"long-url" => "String"}
                       Invalid(status : 404) {"response:" => "No long url for this short url"}
=end 
  def get_long_url
    @url=Url.new
    @url.short_url = params[:urls][:short_url]
    @url_find = Rails.cache.fetch("#{@url.short_url}" , expires_in: 15.minutes) do
      Url.find_by :short_url => @url.short_url
    end
    @url.long_url = @url_find.blank? ? "Not found" : @url_find.long_url
    respond_to do |format|
      if @url.long_url == "Not found"
        @url=Url.new
        flash[:danger] = 'No Short Url Found in Database'
        format.html{render :short_to_long_url,:status=>404}
        format.json {render json: {"response:" => "No long url for this short url"},:status=>404}
      else
        format.html{render :show_long_url}
        format.json {render json: {"long url" => @url_find.long_url}}
      end
    end
  end



  private
    def url_params
      params.require(:url).permit(:long_url)
    end 


end
