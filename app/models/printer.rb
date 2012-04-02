class Printer < ActiveRecord::Base
  MODES = %w[contract memo].freeze

  attr_accessible :country_id, :template, :mode
  attr_protected :company_id

  belongs_to :company
  belongs_to :country
  validates_presence_of :country_id, :if => Proc.new{ self.mode == 'memo' }

  mount_uploader :template, TemplateUploader

  after_destroy { Pathname.new(self.template.path).dirname.delete }

  def prepare_template(fields)
    text = File.read(template.path)

    fields.each do |key, value|
      value ||= ''
      text.gsub!("\#\{#{key.mb_chars.upcase}\}", value.to_s)
    end

    text
  end
end
