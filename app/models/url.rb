require 'elasticsearch/model'

class Url < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  after_create :start
  @@array=[]
  @@max=0
  @@lot=0
  validates :long_url, presence: true, on: :create
  validates :short_url, uniqueness: true, presence: true
  validates :long_url, uniqueness: true, presence: true
  validates_format_of :long_url,
  with: /\A(?:(?:http|https):\/\/*)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@,!:%_\+.~#?&\/\/=]*)?\z/

    

  def self.shorten_url(long_url)
    @url = Url.new
    @url.long_url = long_url
    @url.domain = (Domainatrix.parse(@url.long_url)).domain
    @url.short_url = self.generate_short_url(long_url)
    if @url.save!  
      response = @url.short_url  
      @url_find = Url.find_by :domain => @url.domain, :long_url => @url.long_url
      Rails.cache.write("#{@url.long_url}" ,@url_find  )
    else
      response = "invalid url"
    end 
      return response
    end

    

  def self.generate_short_url(long_url)
    if @@array.empty?
      self.array_filling
    end
    @@array=@@array.shuffle
    @short_url_key=@@array.shift
    short_url = self.base62convert(@short_url_key)
    return short_url
  end

  def self.array_filling
    if @@lot <= 65536
      @@lot+=1
    else
      @@rem+=1
      @@max=@@rem
      @@lot=1
    end
    @@array[0]=@@max
    for i in (1..2048)
      @@array[i]=@@array[i-1]+16777216
    end
    @@max=@@array[2047]
  end

  def self.base62convert(key)
    map = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    key_base_64=""
    while(key>0)
      key_base_64.concat(map[key%62])
      key=key/62
    end 
    key_base_64.reverse!
    return key_base_64
  end

  def start
    CounterWorker.perform_async
  end
end
