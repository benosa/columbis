# -*- encoding : utf-8 -*-
# module MustacheTemplateHandler
#   def self.call(template)
#     haml = "Haml::Engine.new(#{template.source.inspect}).render"
#     if template.locals.include? :mustache
#       "Mustache.render(#{haml}, mustache).html_safe"
#     else
#       haml.html_safe
#     end
#   end
# end
# ActionView::Template.register_template_handler(:mustache, MustacheTemplateHandler)
  
# module SmtRails

#   module Mustache
#     def self.call(template)
#     Rails.logger.debug "template: #{template.to_yaml}"         
#       if template.locals.include?(SmtRails.action_view_key.to_s) || template.locals.include?(SmtRails.action_view_key.to_sym)
#         haml = "Haml::Engine.new(#{template.source.inspect}).render"
#         ::Mustache.template_path = SmtRails.template_base_path
#         "Mustache.render(#{haml}, #{SmtRails.action_view_key.to_s}).html_safe"
#       else
#         "#{template.source.inspect}.html_safe"
#       end
#     end
#   end
# end
