class Task < ActiveRecord::Base
  attr_accessible :user_id, :body, :start_date, :end_date, :executer, :status

  belongs_to :user
  validates :body, :presence => true
end