class Printer < ActiveRecord::Base
  MODES = %w[contract memo]
  attr_accessible :country_id, :template, :mode
  attr_protected :company_id

  belongs_to :company
  belongs_to :country
  validates_presence_of :country_id, :if => Proc.new{ self.mode == 'memo' }

  mount_uploader :template, TemplateUploader

  after_destroy { Pathname.new(self.template.path).dirname.delete }
end
