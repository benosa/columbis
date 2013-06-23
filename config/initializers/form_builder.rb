# Set default form builder
require 'tourism_form_builder'
ActionView::Base.default_form_builder = TourismFormBuilder

# Use custom html wrapper for field with errors
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  errors = Array(instance.error_message).join(', ')
  if html_tag =~ /^<label/
    %(<span class="error_message">#{html_tag}</span>).html_safe
  else
    cls = html_tag[/class="(.+?)"/, 1]
    id = html_tag[/id="(.+?)"/, 1] + '_wrapper'
    %(<div id="#{id}" class="error_message input_wrapper" title="#{errors}">#{html_tag}</div>).html_safe
  end
end