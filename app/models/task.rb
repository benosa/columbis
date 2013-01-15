class Task < ActiveRecord::Base
  belongs_to :user
  validate :body, :presence => true
end