Tourism::Application.routes.draw do

  match 'amount_in_word' => ApplicationController.action(:amount_in_word)
  match 'get_currency_course' => ApplicationController.action(:get_currency_course)

  resources :airlines
  resources :currency_courses

  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      get 'search'
      match 'autocomplete_common/:list' => 'claims#autocomplete_common'
      match 'autocomplete_model_common/:model' => 'claims#autocomplete_model_common'
    end
    member do
      match 'print/:document' => 'claims#print'
    end
  end

  resources :payments
  resources :operators
  resources :tourists
  resources :clients
  resources :addresses
  resources :notes

  resources :catalogs do
    resources :item_fields
    resources :items
  end

  devise_for :users

  namespace :dashboard do
    match 'edit_company' => 'companies#edit'
    match 'get_regions/:country_id' => 'countries#get_regions', :as => :get_regions
    match 'get_cities/:region_id' => 'countries#get_cities', :as => :get_cities

    resources :companies
    resources :dropdown_values, :except => :show
    resources :users

    match '/' => "dashboard#index"
  end

  root :to => 'claims#index'
end
