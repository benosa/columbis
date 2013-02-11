# -*- encoding : utf-8 -*-
module Macros

  def login_as_admin
    admin = FactoryGirl.create(:admin)
    visit new_user_session_path
    fill_in "user[login]", :with => admin.login
    fill_in "user[password]", :with => admin.password
    click_button 'Войти'
    # raise page.body.inspect
    admin
  end
end