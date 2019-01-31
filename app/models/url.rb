require 'elasticsearch/model'

class Url < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  
  validates :long_url, format: { with: /\A(?:(?:http|https):\/\/*)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@,!:%_\+.~#?&\/\/=]*)?\z/}, presence: true, on: :create
  validates :short_url,uniqueness: true
  after_create :start 

  settings index: {
    number_of_shards: 1,
    number_of_replicas: 0,
    analysis: {
      analyzer: {
        pattern: {
          type: 'pattern',
          pattern: "\\s|_|-|\\.",
          lowercase: true
        },
        tetragram: {
          tokenizer: 'tetragram'
        }
      },
      tokenizer: {
        trigram: {
          type: 'ngram',
          min_gram: 4,
          max_gram: 1000,
          token_chars: ['letter', 'digit']
        }
      }
    }
  } do
    mapping do
      indexes :short_url, type: 'text', analyzer: 'english' do
        indexes :keyword, analyzer: 'keyword'
        indexes :pattern, analyzer: 'pattern'
        indexes :trigram, analyzer: 'trigram'
      end
      indexes :long_url, type: 'text', analyzer: 'english' do
        indexes :keyword, analyzer: 'keyword'
        indexes :pattern, analyzer: 'pattern'
        indexes :trigram, analyzer: 'trigram'
      end
    end
  end

  def self.custom_search(params)
    field =  "#{params[:field]}.trigram"
    urls = self.__elasticsearch__.search({
      query: {
        bool: {
          must: [{
            term: {
              field => params[:term]
            }
          }]
         }
        }
      }
    ).records
    return urls
  end


=begin
  def self.shorten_url(long_url)
    @url = Url.new
    @url.long_url = long_url
    @url.domain = (Domainatrix.parse(@url.long_url)).domain
    @domain = Domain.find_by :domain_name => @url.domain
    short_domain = @domain.nil? ? "www.othrs.com/" : @domain.short_domain
    url_hash = self.generate_short_url(long_url)
    short_url_find = Url.find_by :short_url => url_hash
    while !short_url_find.blank?
      url_hash = self.generate_short_url(url_hash)
      short_url_find = Url.find_by :short_url => url_hash
    end
    @url.short_url = short_domain + "/" + url_hash
    if @url.save!  
      return @url
    end
  end
=end
#=begin
  def shorten_url
    @domain = Domain.find_by :domain_name => self.domain
    short_domain = @domain.nil? ? "www.othrs.com/" : @domain.short_domain
    url_hash = self.generate_short_url(self.long_url)
    short_url_find = Url.find_by :short_url => url_hash
    while !short_url_find.blank?
      url_hash = generate_short_url(url_hash)
      short_url_find = Url.find_by :short_url => url_hash
    end
    self.short_url = short_domain + "/" + url_hash
    if self.save!  
      return self
    end
  end
#=end





  def generate_short_url(long_url)
    require 'digest/md5'
=begin
    if @@array.empty?
      self.array_filling
    end
    @@array=@@array.shuffle
    @short_url_key=@@array.shift
    short_url = self.base62convert(@short_url_key)
=end
    return Digest::MD5.hexdigest(long_url)[0,8]
  end

  

=begin
  def self.array_filling
    if @@lot <= 65536
      @@lot+=1
    else
      @@rem+=1
      @@max=@@rem
      @@lot=1
    end
    if @@lot == 1
      @@array[0]=@@max
    else
      @@array[0]=@@max+16777216
    end
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
=end
  


  def start
    CounterWorker.perform_async
  end
end
