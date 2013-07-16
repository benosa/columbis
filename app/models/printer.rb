# -*- encoding : utf-8 -*-
class Printer < ActiveRecord::Base
  MODES = %w[contract memo permit warranty act].freeze

  attr_accessible :country_id, :template, :mode
  attr_protected :company_id

  belongs_to :company, inverse_of: :printers
  belongs_to :country
  validates_presence_of :country_id, :if => Proc.new{ self.mode == 'memo' } # TODO: check company presence

  scope :with_template_name, -> do
    country_columns = Country.columns.map{ |col| "countries.#{col.name} as country_#{col.name}" }
    scope = joins("LEFT JOIN countries ON countries.id = printers.country_id")
      .select(["printers.id", "#{translate_mode} AS mode", "printers.company_id","printers.country_id",
        "(CASE mode WHEN 'memo' THEN concat(countries.name, ' - ', template) ELSE template END) AS template_name"] +
        country_columns)
  end

  define_index do
    indexes "(CASE mode
      WHEN 'contract' THEN '#{I18n.t("activerecord.attributes.printer.contract")}'
      WHEN 'memo' THEN '#{I18n.t("activerecord.attributes.printer.memo")}'
      WHEN 'permit' THEN '#{I18n.t("activerecord.attributes.printer.permit")}'
      WHEN 'warranty' THEN '#{I18n.t("activerecord.attributes.printer.warranty")}'
      WHEN 'act' THEN '#{I18n.t("activerecord.attributes.printer.act")}' END)",
      :as => :mode, :sortable => true
    indexes country(:name), :as => :country_name, :sortable => true
    indexes "(CASE mode WHEN 'memo' THEN concat(countries.name, ' - ', template) ELSE template END)",
      :as => :template_name, :sortable => true

    set_property :delta => true
  end

  sphinx_scope(:by_mode) { { :order => :mode } }
  default_sphinx_scope :by_mode

  mount_uploader :template, TemplateUploader

  extend SearchAndSort

  after_destroy do
    templ_dir = Pathname.new(self.template.path).dirname
    FileUtils.remove_dir(templ_dir, true) if File.exist?(templ_dir)
  end

  def prepare_template(fields, collections)
    @text = File.read(template.path)
    @empty_fields = []

    setup_collections(collections)

    fields.each do |key, value|
      value ||= ''
      upkey = key.mb_chars.upcase
      @text.gsub!(/\#\{#{upkey}\}/) do
        @empty_fields << key if (value == '' and !unrequired_fields.include?(upkey))
        (value.respond_to?(:strftime) ? value.strftime('%d/%m/%Y') : value.to_s)
      end
    end
    @empty_fields.uniq!
    @text.gsub!(/\#\{ПУСТЫЕ_ПОЛЯ\}/, empty_fields_message)

    @text
  end

  private

  def self.translate_mode
    ind = "(CASE mode "
    MODES.each do |mode|
      transl = "activerecord.attributes.printer.#{mode.to_s}"
      ind += "WHEN '#{mode}' THEN '#{I18n.t(transl)}' "
    end
    ind += "END)"
  end

  def setup_collections(collections)
    @empty_collection_fields = {}
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
            upkey = collection_key.mb_chars.upcase
            row.gsub!(/\#\{#{upkey}\}/, (field.respond_to?(:strftime) ? field.strftime('%d/%m/%Y') : field.to_s))
            if (field.to_s == '' and !unrequired_fields.include?(upkey))
              @empty_collection_fields[key] = [] if @empty_collection_fields[key].nil?
              @empty_collection_fields[key][index] = [] if @empty_collection_fields[key][index].nil?
              @empty_collection_fields[key][index] << collection_key
            end
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

  def empty_fields_message
    return '' if @empty_fields.length == 0 and @empty_collection_fields.length == 0
    message = "В документе присутствуют незаполненные поля.\n"
    message += "Список полей: #{@empty_fields.join(', ')}\n" if @empty_fields.length > 0
    Rails.logger.debug "@empty_collection_fields: #{@empty_collection_fields.inspect}"
    @empty_collection_fields.each do |ckey, rows|
      message += "#{ckey}:\n"
      rows.each_with_index { |fields, index| message += "#{index} - #{fields.join(', ')}\n" }
    end
    message.gsub(/\n/, '<br/>')
  end

  def unrequired_fields
    return @unrequired_fields if @unrequired_fields.present?
    @unrequired_fields = []
    s = @text.index('%{НЕОБЯЗАТЕЛЬНЫЕ_ПОЛЯ}').to_i + '%{НЕОБЯЗАТЕЛЬНЫЕ_ПОЛЯ}'.length
    e = @text.index('{НЕОБЯЗАТЕЛЬНЫЕ_ПОЛЯ}%').to_i
    @unrequired_fields += @text[s, e - s].strip.gsub(/[\s\n]/, '').split(',') if (s < e)
    @unrequired_fields
  end
end
