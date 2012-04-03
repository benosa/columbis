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
      collection = value[:collection]

      (/\%\{#{collection_name}\}(.+?)\{#{collection_name}\}\%/m).match(@text)
      match = Regexp.last_match[0]
      partial = Regexp.last_match[1]
      result = ''

      collection.each do |ob|
        str = partial

        value.each  do |collection_key, collection_field|
          next if collection_key == :collection
          collection_field ||= ''.to_sym
          str.gsub!(/\#\{#{collection_key.mb_chars.upcase}\}/, ob.try(collection_field).to_s)
          puts '+++++++++++++++++++++++++++++++++++++++++++++', partial
        end

#        raise partial.inspect

        result += str
      end
#      raise result.inspect
    end
  end
end
