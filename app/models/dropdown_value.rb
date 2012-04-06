class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  attr_protected :company_id
  belongs_to :company

  validates_presence_of :list, :value
  validates_presence_of :company_id, :if => Proc.new { |dd| dd.common == false }
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

  def self.check_and_save(list, value, company_id, common = false)
    unless self.where(:list => list, :value => value, :company_id => company_id).first
      self.create( :list => list, :value => value, :company_id => company_id )
    end
  end

  def self.dd_for(list, company_id, include_common = true)
    DropdownValue.where( 'list = ? AND (company_id = ? OR common = ?)', list, company_id, true ).order('common DESC, value ASC')
  end

  def self.values_for(list, company_id, include_common = true)
    self.dd_for(list, company_id, include_common).map &:value
  end
end
