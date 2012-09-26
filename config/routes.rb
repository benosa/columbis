Tourism::Application.routes.draw do

  match 'amount_in_word' => ApplicationController.action(:amount_in_word)
  match 'get_currency_course' => ApplicationController.action(:get_currency_course)

  resources :airlines
  resources :currency_courses

  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      match 'search' => 'claims#search', :as => :search
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
    match 'sign_in_as/:user_id' => 'users#sign_in_as', :as => :sign_in_as
    match 'edit_company/template/:template' => 'printers#download', :as => :template, :via => :get
    match 'edit_company' => 'companies#edit'
    match 'get_regions/:country_id' => 'countries#get_regions', :as => :get_regions
    match 'get_cities/:region_id' => 'countries#get_cities', :as => :get_cities
    match 'claims/all' => 'claims#all'    

    resources :companies, :except => [:index, :show, :destroy]
    resources :dropdown_values, :except => :show
    resources :users do
      member do
        get :edit_password
        put :update_password
      end
    end
  end

  scope 'dashboard' do
    match 'local_tables' => 'dashboard#local_tables'
    match 'local_data' => 'dashboard#local_data'
  end

  scope 'offline', :defaults => {:offline => 1} do
    resources :tourists
    resources :claims
    resources :operators
    match '/' => "dashboard#offline"
  end
  constraints(:ip => "127.0.0.1") do
    match 'create_manifest' => "dashboard#create_manifest", :via => :post
  end

  match 'dashboard' => "dashboard#index"
  match 'online' => "site#online"

  root :to => 'claims#index'
end
