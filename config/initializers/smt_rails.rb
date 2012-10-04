# -*- encoding : utf-8 -*-
SmtRails.configure do |config|
  config.template_extension = 'mustache' # change extension of mustache templates
  config.action_view_key    = 'mustache' # change name of key for rendering in ActionView mustache template
  config.template_namespace = 'SMT'      # change templates namespace in javascript
  config.template_base_path = Rails.root.join("app", "templates") # templates dir
end
