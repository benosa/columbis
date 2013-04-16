# -*- encoding : utf-8 -*-
Tourism::Application.routes.draw do

  match 'amount_in_word' => 'application#amount_in_word'
  match 'get_currency_course' => 'application#get_currency_course'

  resources :airlines
  resources :currency_courses
  resources :tasks do
    member do
      get 'to_user'
      get 'cancel'
      post 'bug'
      get 'finish'
      get :emails
    end
  end
  match 'create_review' => 'tasks#create_review', as: 'create_review', via: :post
  resources :claims do
    collection do
      get 'autocomplete_tourist_last_name'
      get 'autocomplete_country'
      get 'autocomplete_resort(/:country_id)' => 'claims#autocomplete_resort', :as => 'autocomplete_resort'
      match 'scroll' => 'claims#scroll', as: :scroll
      match 'totals' => 'claims#totals', as: :totals
      put 'update_bonus/:id' => 'claims#update_bonus', :as => 'update_bonus'
      match 'autocomplete_common/:list' => 'claims#autocomplete_common'
      match 'autocomplete_model_common/:model' => 'claims#autocomplete_model_common'
    end
    member do
      match 'print/:document' => 'claims#print'
    end
  end

  resources :payments
  resources :operators do
    match ':id' => :edit, :constraints => {:id => /\d+/}, :on => :collection, :via => :get
  end
  resources :tourists

  # Disable catalogs and addresses
  # resources :addresses
  # resources :notes
  # resources :catalogs do
  #   resources :item_fields
  #   resources :items
  # end

  devise_for :users, :controllers => { :registrations => "registrations" }

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

  namespace :boss do
    match 'reports/:action' => 'reports#:action', :as => :reports
    match '/' => 'base#index', :as => :index
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
