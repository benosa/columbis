Tourism::Application.routes.draw do

  match 'amount_in_word' => ApplicationController.action(:amount_in_word)
  match 'get_currency_course' => ApplicationController.action(:get_currency_course)
  match 'management' => "site#index"

  resources :cities
  resources :countries
  resources :airlines
  resources :offices
  resources :currency_courses
  resources :dropdown_values, :except => :show

  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      match 'autocomplete_city/:country_id' => 'claims#autocomplete_city'
      match 'autocomplete_common/:list' => 'claims#autocomplete_common'
      match 'autocomplete_model_common/:model' => 'claims#autocomplete_model_common'
    end
  end

  resources :payments
  resources :operators
  resources :tourists
  resources :clients
  resources :companies
  resources :addresses

  devise_for :users
  resources :users

  resources :catalogs do
    resources :item_fields
    resources :items
  end

  resources :notes

  root :to => 'claims#index'
end
