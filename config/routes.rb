Tourism::Application.routes.draw do

  resources :cities
  resources :countries
  resources :airlines
  resources :offices
  resources :currency_courses
  resources :reservations

  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      get 'autocomplete_payment_out_form'
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
