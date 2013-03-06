class UserMailer < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :task
  scope :desc_email, order('created_at DESC')
end
