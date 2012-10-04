# -*- encoding : utf-8 -*-
class Company < ActiveRecord::Base
  attr_accessible :email, :country_id, :name, :offices_attributes, :printers_attributes, :address_attributes,
                  :bank, :oficial_letter_signature, :bik, :curr_account, :corr_account, :ogrn, :city_ids, :okpo,
                  :site, :inn

  attr_accessor :company_id

  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :payments_in, :as => :payer, :class_name => 'Payment', :dependent => :destroy
  has_many :payments_out, :as => :recipient, :class_name => 'Payment', :dependent => :destroy

  has_many :users, :dependent => :destroy, :order => 'Last_name ASC'
  has_many :offices, :dependent => :destroy, :order => 'name ASC'
  has_many :claims, :dependent => :destroy
  has_many :tourists, :dependent => :destroy
  has_many :clients, :dependent => :destroy
  has_many :operators, :dependent => :destroy, :order => 'name ASC'
  has_many :dropdown_values, :dependent => :destroy

  has_many :city_companies, :dependent => :destroy
  has_many :cities, :through => :city_companies, :order => :name, :uniq => true
  has_many :countries, :through => :cities, :group => 'countries.name, countries.id', :order => :name

  has_many :printers, :order => :id, :dependent => :destroy

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :offices, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :printers, :reject_if => :check_printers_attributes, :allow_destroy => true

  validates_presence_of :name

  def company_id
    id
  end

  def contract_printer
    printers.where(:mode => 'contract').last
  end

  def memo_printer_for(country)
    printers.where(:mode => 'memo', :country_id => country).last
  end

  def permit_printer
    printers.where(:mode => 'permit').last
  end

  def warranty_printer
    printers.where(:mode => 'warranty').last
  end

  def act_printer
    printers.where(:mode => 'act').last
  end

  def check_and_save_dropdown(list, value)
    DropdownValue.check_and_save(list, value, id)
  end

  def dropdown_for(list)
    DropdownValue.dd_for(list, id)
  end

  def dropdown_values_for(list)
    DropdownValue.values_for(list, id)
  end

  private

    def check_printers_attributes(attributes)
      if attributes['id'].present?
        # Will not update template field if it is blank
        attributes.delete 'template' if attributes['template'].blank?
        false
      else
        attributes['template'].blank?
      end      
    end
end
