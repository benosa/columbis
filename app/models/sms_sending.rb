class SmsSending < ActiveRecord::Base
  attr_accessible :company_id, :contact_group_id, :content, :count, :delivered_count, :send_an, :sending_priority, :signature, :status_id, :user_id
end
