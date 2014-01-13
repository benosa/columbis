class ImportInfo < ActiveRecord::Base
  attr_accessible :company_id, :count, :filename, :integer, :load_date, :num, :success_count
  belongs_to :company
  has_many :import_items, :dependent => :destroy

  before_save :generate_num

  def generate_num
    if company.present? && num.to_i == 0
      self.num = ImportInfo.where(company_id: company_id).maximum(:num).to_i + 1
    end
  end
end
