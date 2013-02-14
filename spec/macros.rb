# -*- encoding : utf-8 -*-
module Macros

  def login_as_admin
    admin = FactoryGirl.create(:admin)
    visit new_user_session_path
    fill_in "user[login]", :with => admin.login
    fill_in "user[password]", :with => admin.password
    click_button 'user_session_submit'
    admin
  end

  def random_datetime(from = nil, to = nil)
    from ||= Time.now - 1.week
    to ||= Time.now + 1.week
    rand(from..to)
  end

  def sphinx_environment(*tables, &block)
    obj = self
    begin
      before(:all) do
        obj.use_transactional_fixtures = false
        DatabaseCleaner.strategy = :truncation, {:only => tables}
        ThinkingSphinx::Test.create_indexes_folder
        ThinkingSphinx::Test.start
      end

      before(:each) do
        DatabaseCleaner.start
      end

      after(:each) do
        DatabaseCleaner.clean
      end

      yield
    ensure
      after(:all) do
        ThinkingSphinx::Test.stop
        DatabaseCleaner.strategy = :transaction
        obj.use_transactional_fixtures = true
      end
    end
  end

  def wait_for_filter_refresh(seconds = Capybara.default_wait_time)
    # wait_until(seconds) { page.has_no_selector?('.refreshing') } or puts("Ran out of time waiting for ajax refresh.\n")
    wait_until(seconds) { !page.find('#ajax-indicator').visible? }
  rescue Capybara::TimeoutError
    flunk 'Expected ajax indicator to be hidden'
  end
end