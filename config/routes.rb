Tourism::Application.routes.draw do

  match 'amount_in_word' => ApplicationController.action(:amount_in_word)
  match 'get_currency_course' => ApplicationController.action(:get_currency_course)
  match 'management' => "site#index"

  resources :cities
  resources :countries
  resources :airlines
  resources :offices, :except => :show
  resources :currency_courses
  resources :dropdown_values, :except => :show

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
  resources :companies
  resources :addresses
  resources :notes

  resources :catalogs do
    resources :item_fields
    resources :items
  end


  devise_for :users
  resources :users

  root :to => 'claims#index'
end
