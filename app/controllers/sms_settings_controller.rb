class SmsSettingsController < ApplicationController
  def index
    @company = Company.find(current_company.id)
  end
  
  def update
    @company = Company.find(current_company.id)
    if @company.update_attributes(params[:company])
      redirect_to sms_settings_path, notice: 'sms settings was successfully updated'
    else
      redirect_to sms_settings_path, alert: 'sms settings was not updated'
    end
  end
end
