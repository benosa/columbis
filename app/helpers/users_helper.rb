# -*- encoding : utf-8 -*-
module UsersHelper
  def check_field(resource)
    if resource.errors.messages[:email][0].to_s == ''
      tag(:input, :id => "user_check", :type => "text", :name => "user[_check]", :class => "required")
    else
      content_tag(:div, :class => 'error_message input_wrapper',:title => resource.errors.messages[:email].join(", ")) do
        tag(:input, :id => "user_check", :type => "text", :name => "user[_check]", :class => "required")
      end
    end
  end

  def get_demo_user
  	User.where(login: 'demo').first
  end

  def is_demo_user?
  	current_user == get_demo_user
  end
end
