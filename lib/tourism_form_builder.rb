# -*- encoding : utf-8 -*-
class TourismFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(*args)
    super(*args)
    @highlighted_options = {
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

      wrapper_options = options.delete(:wrapper)

      args << options
      content = super(name, *args)
      content = wrapper(method_name, name, content, wrapper_options, options) if wrapper?(wrapper_options)
      content
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
    args << options
    if required
      options[:class] = add_required_class(options[:class])
      options[:title] = I18n.t('required_field')
      tag = super(name, *args)
      # tag.sub!(/<\/label>/, ' *</label>')
      # tag.html_safe
    else
      super(name,  *args)
    end
  end

  # Render error messages. The :message and :header_message options are allowed.
  def error_messages(options = {})
    header_message = options[:header_message] ||
      I18n.t(:"activerecord.errors.header", :default => I18n.t('invalid_fields')) unless options[:header_message] === false
    message = options[:message] ||
      I18n.t(:"activerecord.errors.message", :default => I18n.t('correct_the_following_errors_and_try_again')) unless options[:message] === false

    # messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    messages = @object.errors.full_messages
    unless messages.empty?
      @template.instance_exec do
        content_tag(:div, :class => "error_messages") do
          content = ''
          content += content_tag(:h2, header_message) if header_message
          content += content_tag(:p, message) if message
          content += content_tag(:ul, messages.map { |msg| content_tag(:li, msg) }.join.html_safe)
          content.html_safe
        end
      end
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

    def highlight?(name, options)
      return false unless @highlighted_options[:on] && name
      h = required?(name)
      if options[:highlighted].present? or options[:not_highlighted].present?
        h = options[:highlighted] and !options[:not_highlighted]
      else
        h &&= !@highlighted_options[:except].include?(name) if h and @highlighted_options[:except].present?
        h &&= @highlighted_options[:only].include?(name) if @highlighted_options[:only].present?
      end
      h
    end

    def wrapper?(wrapper_options)
      @options[:wrapper] and !(wrapper_options === false)
    end

    def wrapper(method_name, name, content, wrapper_options, options)
      wrapper_options = {} unless wrapper_options
      wrap_class = wrapper_options.delete(:wrap_class)
      _options = {}
      _options[:class] = "#{wrapper_options[:class] || ''} #{wrap_class || wrap_class(method_name, name)}".strip unless wrap_class === false
      _options[:class] = "#{_options[:class]} highlight".strip if highlight?(name, options)
      _options.reverse_merge! wrapper_options
      @template.content_tag('div', content, _options)
    end

    def wrap_class(method_name, name)
      type = case
      when %w(text_field password_field).include?(method_name) then 'input'
      when method_name == 'text_area' then 'textarea'
      else method_name
      end
      "wrap-#{type} #{name}-wrap"
    end

end
