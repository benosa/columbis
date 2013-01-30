# -*- encoding : utf-8 -*-
class TourismFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(*args)
    super(*args)
    @highlighted_options ||= {
      :on => @options[:highlight].present? ? @options[:highlight] : false,
      :only => @options[:highlight_only].present? ? @options[:highlight_only].to_a : nil,
      :except => @options[:highlight_except].present? ? @options[:highlight_except].to_a : nil
    }
  end

  def self.create_wrapped_field(method_name)
    define_method(method_name) do |name, *args|
      options = args.extract_options!

      required = options.delete(:required)
      required = required?(name) if required.nil?
      options[:class] = add_required_class(options[:class]) if required

      highlight = if @highlighted_options[:on] && name
        h = required?(name)
        if options[:highlighted].present? or options[:not_highlighted].present?
          h = options[:highlighted] and !options[:not_highlighted]
        else
          h &&= !@highlighted_options[:except].include?(name) if h and @highlighted_options[:except].present?
          h &&= @highlighted_options[:only].include?(name) if @highlighted_options[:only].present?
        end
        h
      end

      args << options
      if highlight
        @template.content_tag('div', super(name, *args), :class => 'highlighted')
      else
        super(name, *args)
      end
    end
  end

  # field_helpers.each do |name|
  %w[text_field text_area password_field select].each do |name|
    create_wrapped_field(name)
  end

  def label(name, *args)
    options = args.extract_options!

    required = options.delete(:required)
    required = required?(name) if required.nil?
    if required
      options[:class] = add_required_class(options[:class])
      options[:title] = I18n.t('required_field')
      tag = super(name, *(args << options))
      # tag.sub!(/<\/label>/, ' *</label>')
      # tag.html_safe
    else
      super(name,  *(args << options))
    end
  end

  private

    def required?(name)
      return false unless @object.class.respond_to?(:validators_on)
      @object.class.validators_on(name).any? { |v| v.instance_of? ActiveModel::Validations::PresenceValidator }
    end

    def add_required_class(str)
      r = str ? str : ''
      r << ' required'
      r.strip
    end

end
