Tourism::Application.routes.draw do
  match 'claims/autocomplete_common/:list' => 'claims#autocomplete_common'
  match 'claims/autocomplete_model_common/:model' => 'claims#autocomplete_model_common'

  resources :cities
  resources :countries
  resources :airlines
  resources :offices
  resources :currency_courses
  resources :dropdown_values, :except => :show

  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      post 'amount_in_word'
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

  root :to => 'site#index'
end
