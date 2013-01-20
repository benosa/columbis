class Task < ActiveRecord::Base
  STATUS = [ 'new','work','cancel','finish' ]
  attr_accessible :user_id, :body, :start_date, :end_date, :executer, :status, :bug

  belongs_to :user
  belongs_to :executer, :foreign_key => 'executer_id', :class_name => 'User'
  validates :body, :presence => true

  scope :order_bug, order('bug DESC')
  scope :order_created, order('created_at DESC')
  scope :by_status, ->(status) { where(status: status) }

  scope :filtered, ->(filter) {
    filter.inject(scoped) do |combine_scope, (field, value)|
      case field.to_sym
        when :status then
          combine_scope.by_status(value.presence || ['new', 'work'])
        when :user_id then
          combine_scope.where(user_id: filter[:user_id])
      end
    end
  }
end