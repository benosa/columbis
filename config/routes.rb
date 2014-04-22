# -*- encoding : utf-8 -*-
Tourism::Application.routes.draw do

  post "visitors/create"
  get "visitors/confirm"

  get '/claim_print/:claim_id/:printer' => 'claim_printers#edit', as: 'edit_claim_printers'
  put '/claim_print/:claim_id/:printer' => 'claim_printers#update', as: 'update_claim_printers'
  put '/claim_print/:claim_id/:printer/delete' => 'claim_printers#delete', as: 'delete_claim_printers'
  get '/claim_print/:claim_id/:printer/print' => 'claim_printers#print', as: 'print_claim_printers'

  resources :user_payments, :except => [:show, :edit, :update]

  resources :tariff_plans
  get 'sms_settings' => 'sms_settings#index', as: 'sms_settings'
  put 'sms_settings' => 'sms_settings#update', as: 'sms_settings'

  resources :sms_groups do
    collection do
      put :batch_add_to_group
    end
  end

  match 'sms_groups_birthday' => 'sms_groups#birthday', as: 'sms_groups_birthday', via: :get

  resources :sms_sendings

  scope 'robokassa' do # Robokassa routes
    post 'paid'    => 'robokassa#paid',    :as => :robokassa_paid # to handle Robokassa push request
    get 'success' => 'robokassa#success', :as => :robokassa_success # to handle Robokassa success redirect
    get 'fail'    => 'robokassa#fail',    :as => :robokassa_fail # to handle Robokassa fail redirect
  end

  match 'amount_in_word' => 'application#amount_in_word'
  match 'get_currency_course' => 'application#get_currency_course'
  match 'current_timestamp' => "application#current_timestamp"
  get "/uploads/:company_id/*file" => 'uploads#show', :as => 'file', :format => false
  get 'download_template/:template' => 'printers#download', :as => :download_template

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
      scope 'autocomplete', as: 'autocomplete', controller: 'claims_autocomplete' do
        get 'tourist'
        get 'city'
        get 'operator'
        get 'country'
        get 'resort(/:country_id)' => 'claims_autocomplete#resort', as: 'resort'
        get 'dropdown/:list' => 'claims_autocomplete#dropdown', as: 'dropdown'
      end
      get 'scroll' => 'claims#scroll', as: :scroll
      get 'totals' => 'claims#totals', as: :totals
      put 'update_bonus/:id' => 'claims#update_bonus', :as => 'update_bonus'
      put 'lock/:id' => 'claims#lock', :as => 'lock'
      put 'unlock/:id' => 'claims#unlock', :as => 'unlock'
    end
    member do
      match 'print/:document' => 'claims#print'
    end
  end

  resources :printers, :except => :show
  resources :countries
  resources :cities
  resources :payments
  resources :operators
  get '/operators/refresh/:id' => 'operators#refresh', as: 'operator_refresh'
  get '/operators/refresh_check/:id' => 'operators#refresh_check', as: 'operator_refresh_check'
  post '/operators/create_own/:id' => 'operators#create_own', as: 'operator_create_own'
  post '/operators/destroy_own/:id' => 'operators#destroy_own', as: 'operator_destroy_own'
  resources :tourists

  # Disable catalogs and addresses
  # resources :addresses
  # resources :notes
  # resources :catalogs do
  #   resources :item_fields
  #   resources :items
  # end

  devise_for :users, :controllers => { :registrations => "registrations", :passwords => "passwords",
    :sessions => "sessions", :confirmations => "confirmations" }

  namespace :dashboard do
    match 'sign_in_as/:user_id' => 'users#sign_in_as', :as => :sign_in_as, :via => [:get, :post]
    get 'edit_company/template/:template' => 'printers#download', :as => :template
    get 'edit_company' => 'companies#edit'
    put 'edit_company' => 'companies#update'
    get 'get_regions/:country_id' => 'countries#get_regions', :as => :get_regions
    get 'get_cities/:region_id' => 'countries#get_cities', :as => :get_cities
    get 'export' => 'data_transfer#export'
    get 'check_export' => 'data_transfer#check_export', :as => :check_export
    post 'import' => 'data_transfer#import'
    get 'data_index' => 'data_transfer#index'

    resources :companies, :except => [:index, :show, :destroy]
    resources :dropdown_values, :except => :show
    resources :users
  end

  namespace :boss do
    match 'reports/:action' => 'reports#:action', :as => :reports
    match '/' => 'base#index', :as => :index
    post '/sort_widget' => 'base#sort_widget', :as => :sort_widget
    post '/save_widget_settings' => 'base#save_widget_settings', :as => :save_widget_settings
    post '/delete_widget' => 'base#delete_widget', :as => :delete_widget
  end

  namespace :admin do
    match '/' => 'base#index', :as => :index
    match '/instructions' => 'base#instructions', :as => :instructions
    match '/visitors' => 'base#visitors', :as => :visitors
    get '/companies/:company_id/edit' => 'base#companies_edit', :as => :companies_edit
    put '/companies/:company_id' => 'base#companies_update', :as => :companies_update
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

  match "/dj" => DelayedJobWeb, :anchor => false

  match '*path' => 'application#routing_error'
end
