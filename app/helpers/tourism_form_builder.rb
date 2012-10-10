class TourismFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_wrapped_field(method_name)
    define_method(method_name) do |name, *args|
      options = args.dup.extract_options!
      if !options[:not_highlighted] and @object.class.validators_on(name).any? { |v| v.instance_of? ActiveModel::Validations::PresenceValidator }
        @template.content_tag('div', super(name, *args), :class => "highlighted #{method_name}")
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