Tourism::Application.routes.draw do
  devise_for :users
  resources :users

  resources :airlines
  resources :offices
  resources :currency_courses
  resources :reservations
  resources :claims
  resources :payments
  resources :operators
  resources :tourists
  resources :clients
  resources :companies
  resources :addresses

  resources :catalogs do
    resources :item_fields
    resources :items
  end

  resources :notes

  root :to => 'site#index'
end
