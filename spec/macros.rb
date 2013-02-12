# -*- encoding : utf-8 -*-
module Macros

  def login_as_admin
    admin = FactoryGirl.create(:admin)
    visit new_user_session_path
    fill_in "user[login]", :with => admin.login
    fill_in "user[password]", :with => admin.password
    click_button 'user_session_submit'
    # raise page.body.inspect
    admin
  end

  def random_datetime(from = nil, to = nil)
    from ||= Time.now - 1.week
    to ||= Time.now + 1.week
    rand(from..to)
  end
end