class SmsSending < ActiveRecord::Base
  attr_accessible :company_id, :sms_group_id, :content, :count, :delivered_count, :sending_at, :sending_priority, :signature, :status, :user_id
  attr_accessible :sending_at_date, :sending_at_time_hour, :sending_at_time_minute
  
  validates :sms_group_id, presence: true
  validates :content, presence: true,
                      length: { maximum: 165 }
                      
  scope :current_company, lambda { |id| where(company_id: id) }
end
