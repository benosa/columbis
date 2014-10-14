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

  def demo_user
  	@demo_user ||= User.where(login: 'demo').first
  end

  def demo_user?
  	current_user == demo_user
  end

  def show_demo_enter
    !demo_user? && current_company.claims_count.to_i < CONFIG[:claim_count_for_demo]
  end

  def show_demo_exit
    demo_user? && logged_as_another_user?
  end

  def user_edit_url(resource)
    root_url(subdomain: resource.try(:company).try(:subdomain)).to_s +
      url_for(:controller => 'registrations', :action => 'edit').to_s.gsub(/^./, "")
  end

end
