# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## die die die
#[Company, Address, Airline,  Catalog, CityCompany, Claim, Client, CurrencyCourse,
#DropdownValue, Item, ItemField, Note, Office, Operator, Payment, Printer, Tourist, TouristClaim, User,
#Country, City, Region].map{ |c| c.destroy_all}


[
  { :list => 'form', :value => 'Наличный' },
  { :list => 'form', :value => 'Безналичный' },
  { :list => 'tourist_stat', :value => 'Интернет' },
  { :list => 'tourist_stat', :value => 'Реклама ТВ' },
  { :list => 'tourist_stat', :value => 'Знакомый' },
  { :list => 'placement', :value => 'SNGL' },
  { :list => 'placement', :value => 'DBL' },
  { :list => 'placement', :value => 'DBL+CLD' },
  { :list => 'placement', :value => 'DBL+2CHLD' }
].each do |params_hash|
  DropdownValue.create(params_hash.reverse_merge(:common => true)) if DropdownValue.where(params_hash.reverse_merge(:common => true)).empty?
end

#plain_sql = File.open(Rails.root.join("db/geo_utf.sql")).read
#connection = ActiveRecord::Base.connection();
#connection.execute(plain_sql)
