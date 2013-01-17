class Task < ActiveRecord::Base
  STATUS = [ 'new', 'work', 'delete']
  attr_accessible :user_id, :body, :start_date, :end_date, :executer, :status, :bug

  belongs_to :user
  belongs_to :executer, :foreign_key => 'executer_id', :class_name => 'User'
  validates :body, :presence => true
end