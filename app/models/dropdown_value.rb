class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  attr_protected :company_id
  belongs_to :company

  validates_presence_of :list, :value, :company_id
  validates_uniqueness_of :value, :scope => [:company_id, :list]

  def self.available_lists
    { :relocation => 'Переезд',
      :hotel => 'Отель',
      :form => 'Форма оплаты',
      :airport => 'Аэропорт',
      :transfer => 'Трансфер',
      :meals => 'Питание',
      :service_class => 'Класс',
      :tourist_stat => 'Откуда турист'
    }
  end

  def self.check_and_save(list, value, company_id)
    unless self.where(:list => list, :value => value, :company_id => company_id).first
      self.create( :list => list, :value => value, :company_id => company_id )
    end
  end

  def self.dd_for(list, company_id)
    DropdownValue.where( :list => list, :company_id => company_id )
  end

  def self.values_for(list, company_id)
    DropdownValue.where( :list => list, :company_id => company_id ).map &:value
  end

  def self.method_missing(meth, *args, &block)
    # just returns values for certain list
    if meth.to_s =~ /^dd_for_(.+)$/
      # returns as an AR-objects array
      # for example: DropdownValue.dd_for_payment_form. where list name is 'payment_form'
      DropdownValue.where( :list => $1 )
    elsif meth.to_s =~ /^values_for_(.+)$/
      # returns as a string array
      # for example: DropdownValue.values_for_payment_form. where list name is 'payment_form'
      DropdownValue.where( :list => $1 ).map &:value
    else
      super
    end
  end
end
