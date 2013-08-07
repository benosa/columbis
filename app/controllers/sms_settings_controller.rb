class SmsSettingsController < ApplicationController
  def index
    @company = Company.find(current_company.id)
  end
end
