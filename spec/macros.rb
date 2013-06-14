# -*- encoding : utf-8 -*-
module Macros

  def self.included(base)
    base.extend(ClassMethods)
  end

  def create_user_with_company_and_office(factory = :user)
    company = FactoryGirl.create(:company)
    office = FactoryGirl.create(:office, company: company)
    user = FactoryGirl.create(factory, company: company, office: office)
  end

  def create_users_with_company_and_office(factory = :user, count = 2)
    company = FactoryGirl.create(:company)
    office = FactoryGirl.create(:office, company: company)
    FactoryGirl.create(factory, company: company, office: office)
    users = []
    count.times { users << FactoryGirl.create(factory, company: company, office: office) }
    users
  end
  
  def create_claims(company, user)
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "интернет", hotel: "5*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-02")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "друг", hotel: "5*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-02")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "знакомый", hotel: "1*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-07")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "турагентство", hotel: "2*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-10")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "сам увидел", hotel: "3*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-12")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "телевидение", hotel: "4*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-20")
    FactoryGirl.create(:claim, company: company, user: user, tourist_stat: "газета", hotel: "4*", reservation_date: Time.zone.now, arrival_date: "2013-01-01", departure_date: "2013-01-20")
  end

  def login_as_admin
    # company = FactoryGirl.create(:company)
    # office = FactoryGirl.create(:office)
    admin = create_user_with_company_and_office(:admin)
    # country = FactoryGirl.create(:country)
    login_as admin
  end
  
  def login_as(user)
    visit new_user_session_path
    fill_in "user[login]", :with => user.login
    fill_in "user[password]", :with => user.password
    page.click_button 'user_session_submit'
    user
  end

  def random_datetime(from = nil, to = nil)
    from ||= Time.zone.now - 1.week
    to ||= Time.zone.now + 1.week
    rand(from..to)
  end

  def wait_for_filter_refresh(seconds = Capybara.default_wait_time)
    # wait_until(seconds) { page.has_no_selector?('.refreshing') } or puts("Ran out of time waiting for ajax refresh.\n")
    wait_until(seconds) { 
      # puts page.find('#ajax-indicator').visible?.inspect
      !page.find('#ajax-indicator').visible? 
    } #or puts("Ran out of time waiting for ajax refresh.\n")
  rescue Capybara::TimeoutError
    flunk 'Expected ajax indicator to be hidden'
  end

  def fill_in_with_trigger(field, options = {})
    trigger = options.delete(:trigger) || 'change'
    fill_in(field, options)
    page.execute_script "$(':input[name=\"#{field}\"]').trigger('#{trigger}')"
  end

  module ClassMethods

    def clean(options = {}, &block)
      obj = self
      hook = options[:hook] or :each
      tables = options[:tables]
      strategy = options[:strategy] or :transaction
      begin
        before(hook) do
          obj.use_transactional_fixtures = false unless strategy == :transaction
          DatabaseCleaner.strategy = strategy, {:only => tables}
          DatabaseCleaner.start
          options[:before].call if options[:before].respond_to?(:call)
        end

        yield
      ensure
        after(hook) do
          options[:after].call if options[:after].respond_to?(:call)
          DatabaseCleaner.clean
          obj.use_transactional_fixtures = true
        end
      end
    end

    def clean_each(options = {}, &block)
      clean options.merge!({ hook: :each }), &block
    end

    def clean_once(options = {}, &block)
      clean options.merge!({ hook: :all }), &block
    end

    def clean_once_with_sphinx(options = {}, &block)
      options.merge!({
        strategy: :truncation,
        before: proc { ThinkingSphinx::Test.start },
        after:  proc { ThinkingSphinx::Test.stop }
      })
      clean_once options, &block
    end

  end

end

