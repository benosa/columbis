# -*- encoding : utf-8 -*-
class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  attr_protected :company_id
  belongs_to :company

  validates_presence_of :list, :value
  validates_presence_of :company_id, :if => Proc.new { |dd| dd.common == false }
  validates_uniqueness_of :value, :scope => [:company_id, :list]

  scope :common, where(:common => true)

  def self.available_lists
    {
      :airline => 'Авиакомпания',
      :relocation => 'Переезд',
      :hotel => 'Отель',
      :form => 'Форма оплаты',
      :airport => 'Аэропорт',
      :transfer => 'Трансфер',
      :meals => 'Питание',
      :service_class => 'Класс',
      :tourist_stat => 'Откуда турист',
      :placement => 'Размещение',
	    :medical_insurance => 'Медстраховка',
	    :transfer => 'Трансфер',
      :nights => 'Кол-во ночей',
			:service_class => 'Класс',
			:relocation => 'Переезд'
    }
  end

  def self.check_and_save(list, value, company_id, common = false)
    # Clean value from trailing spaces
    value.strip! if value.is_a? String
    unless where(:list => list, :value => value, :company_id => company_id).first
      # we don't store common values
      return if where(:list => list, :value => value, :common => true).first

      dd = new( :list => list, :value => value )
      dd.company_id = company_id
      dd.save
    end
  end

  def self.dd_for(list, company_id, include_common = true)
    DropdownValue.where( 'list = ? AND (company_id = ? OR common = ?)', list, company_id, true ).order('common DESC, value ASC')
  end

  def self.values_for(list, company_id, include_common = true)
    self.dd_for(list, company_id, include_common).map &:value
  end
end
