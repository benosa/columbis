# -*- encoding : utf-8 -*-
module UsersHelper
  def check_field(resource)
    if resource.errors.messages[:email][0].to_s == ''
      tag(:input, :id => "user_check", :type => "text", :name => "user[check]", :class => "required")
    else
      content_tag(:div, :class => 'error_message input_wrapper',:title => resource.errors.messages[:email].join(", ")) do
        tag(:input, :id => "user_check", :type => "text", :name => "user[check]", :class => "required")
      end
    end
  end
end
