class Printer < ActiveRecord::Base
  MODES = %w[contract memo permit warranty act].freeze

  attr_accessible :country_id, :template, :mode
  attr_protected :company_id

  belongs_to :company
  belongs_to :country
  validates_presence_of :country_id, :if => Proc.new{ self.mode == 'memo' } # TODO: check company presence

  mount_uploader :template, TemplateUploader

  after_destroy { Pathname.new(self.template.path).dirname.delete if File.exist?(Pathname.new(self.template.path).dirname) }

  def prepare_template(fields, collections)
    @text = File.read(template.path)

    setup_collections(collections)

    fields.each do |key, value|
      value ||= ''
      @text.gsub!(/\#\{#{key.mb_chars.upcase}\}/, (value.respond_to?(:strftime) ? value.strftime('%d/%m/%Y') : value.to_s))
    end

    @text
  end

  private

  def setup_collections(collections)
    collections.each do |key, value|
      collection_name = key.mb_chars.upcase.to_s        
      @text.scan(/(\%\{#{collection_name}\}(.+?)\{#{collection_name}\}\%)/m).each do |matches|
        collection = value[:collection]
        match = matches[0].clone        
        partial = ''<< matches[1].clone
        result = ''

        index = 0
        collection.each do |ob|
          row = partial.clone
          value.each  do |collection_key, collection_field|
            next if collection_key == :collection
            collection_field ||= ''.to_sym
            field = ob.try(collection_field)
            row.gsub!(/\#\{#{collection_key.mb_chars.upcase}\}/, (field.respond_to?(:strftime) ? field.strftime('%d/%m/%Y') : field.to_s))
          end
          # Computed expressions
          row.gsub!(/\=\{(.+?)\}/) do |m|
            begin
              eval($1)
            rescue Exception => e
              ''
            end
          end          
          result += row
          index += 1
        end
        @text.gsub!(match, result)
      end
    end
  end
end
