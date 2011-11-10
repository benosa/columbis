# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111109123322) do

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "region"
    t.integer  "zip_code"
    t.string   "house_number"
    t.string   "housing"
    t.string   "office_number"
    t.string   "street"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "airlines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "catalogs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.integer  "country_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "claims", :force => true do |t|
    t.integer  "user_id"
    t.text     "description"
    t.datetime "check_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "office_id"
    t.integer  "operator_id"
    t.string   "operator_confirmation"
    t.string   "visa",                       :default => "nothing_done", :null => false
    t.string   "airport_to"
    t.string   "airport_back"
    t.string   "flight_to"
    t.string   "flight_back"
    t.string   "depart_to"
    t.string   "depart_back"
    t.datetime "visa_check"
    t.float    "tour_price",                 :default => 0.0
    t.float    "visa_price",                 :default => 0.0
    t.float    "insurance_price",            :default => 0.0
    t.float    "additional_insurance_price", :default => 0.0
    t.float    "fuel_tax_price",             :default => 0.0
    t.float    "total_tour_price",           :default => 0.0
    t.float    "primary_currency_price",     :default => 0.0
    t.float    "course",                     :default => 0.0
    t.string   "currency",                                               :null => false
    t.integer  "airline_id"
    t.integer  "num"
    t.integer  "visa_count"
    t.string   "meals"
    t.string   "placement"
    t.integer  "nights"
    t.string   "hotel"
    t.datetime "arrival_date"
    t.datetime "departure_date"
  end

  add_index "claims", ["num"], :name => "index_claims_on_num"

  create_table "clients", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.integer  "passport_series"
    t.integer  "passport_number"
    t.string   "phone_number"
    t.string   "address"
    t.date     "passport_valid_until"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "email"
    t.string   "oficial_letter_signature"
    t.integer  "country_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currency_courses", :force => true do |t|
    t.integer  "user_id"
    t.datetime "on_date",                     :null => false
    t.string   "currency",                    :null => false
    t.float    "course",     :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currency_courses", ["currency", "on_date"], :name => "index_currency_courses_on_currency_and_on_date"

  create_table "dropdown_values", :force => true do |t|
    t.string "list"
    t.string "value"
  end

  add_index "dropdown_values", ["list"], :name => "index_dropdown_values_on_list"
  add_index "dropdown_values", ["value"], :name => "index_dropdown_values_on_value"

  create_table "item_fields", :force => true do |t|
    t.integer  "catalog_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "catalog_id"
  end

  create_table "notes", :force => true do |t|
    t.integer  "item_id"
    t.integer  "item_field_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offices", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operators", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "claim_id"
    t.datetime "date_in",                         :null => false
    t.integer  "payer_id",                        :null => false
    t.string   "payer_type",                      :null => false
    t.integer  "recipient_id",                    :null => false
    t.string   "recipient_type",                  :null => false
    t.string   "currency",                        :null => false
    t.float    "amount",         :default => 0.0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "form",                            :null => false
  end

  create_table "tourist_claims", :force => true do |t|
    t.integer  "claim_id"
    t.integer  "tourist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "applicant",  :default => false
  end

  create_table "tourists", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.integer  "passport_series"
    t.integer  "passport_number"
    t.date     "date_of_birth"
    t.date     "passport_valid_until"
    t.string   "phone_number"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.integer  "office_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
