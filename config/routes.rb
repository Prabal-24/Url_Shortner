Rails.application.routes.draw do
  get 'welcome/index'
  get 'daily_reports' =>'daily_reports#index'
  devise_for :users
  root 'welcome#index'
  get 'users/new'
  get 'urls/short_to_long_url'
  resources:urls
  post 'get_short_url' => 'urls#get_short_url'
  post 'urls/new' => 'urls#get_short_url'
  get 'get_long_url' => 'urls#get_long_url'
  get 'search' => 'search#search'
  get 'search/search_result' => 'search#search_result'
  require 'sidekiq/web'  
  mount Sidekiq::Web, :at => '/sidekiq'  
end
