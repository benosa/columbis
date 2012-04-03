class Printer < ActiveRecord::Base
  MODES = %w[contract memo].freeze

  attr_accessible :country_id, :template, :mode
  attr_protected :company_id

  belongs_to :company
  belongs_to :country
  validates_presence_of :country_id, :if => Proc.new{ self.mode == 'memo' }

  mount_uploader :template, TemplateUploader

  after_destroy { Pathname.new(self.template.path).dirname.delete }

  def prepare_template(fields, collections)
    @text = File.read(template.path)

    setup_collections(collections)

    fields.each do |key, value|
      value ||= ''
      @text.gsub!(/\#\{#{key.mb_chars.upcase}\}/, value.to_s)
    end

    @text
  end

  private

  def setup_collections(collections)
    collections.each do |key, value|
      collection_name = key.mb_chars.upcase.to_s
      if (/\%\{#{collection_name}\}(.+?)\{#{collection_name}\}\%/m).match(@text)
        collection = value[:collection]
        match = Regexp.last_match[0].clone
        partial = ''<< Regexp.last_match[1].clone
        result = ''

        collection.each do |ob|
          row = partial.clone
          value.each  do |collection_key, collection_field|
            next if collection_key == :collection
            collection_field ||= ''.to_sym
            field = ob.try(collection_field)
            row.gsub!(/\#\{#{collection_key.mb_chars.upcase}\}/, (field.respond_to?(:strftime) ? field.strftime('%d/%m/%Y') : field.to_s))
          end
          result += row
        end
        @text.gsub!(match, result)
      end
    end
  end
end
