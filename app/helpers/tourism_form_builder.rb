class TourismFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(*args)
    super(*args)
    @highlighted_options ||= {
      :only => @options[:highlight_only].present? ? @options[:highlight_only].to_a : nil,
      :except => @options[:highlight_except].present? ? @options[:highlight_except].to_a : nil
    }
    Rails.logger.debug "@highlighted_options: #{@highlighted_options.to_yaml}"
end

  def self.create_wrapped_field(method_name)
    define_method(method_name) do |name, *args|
      options = args.dup.extract_options!
      if options[:highlighted] or options[:not_highlighted]
        highlight = options[:highlighted] and !options[:not_highlighted]
      else
        highlight = @object.class.validators_on(name).any? { |v| v.instance_of? ActiveModel::Validations::PresenceValidator }
        highlight &&= !@highlighted_options[:except].include?(name) if highlight and @highlighted_options[:except].present?
        highlight &&= @highlighted_options[:only].include?(name) if @highlighted_options[:only].present?
      end

      if highlight
        @template.content_tag('div', super(name, *args), :class => "highlighted")
      else
        super(name, *args)
      end
    end
  end

  # field_helpers.each do |name|
  %w[text_field text_area password_field select].each do |name|
    create_wrapped_field(name)
  end
end