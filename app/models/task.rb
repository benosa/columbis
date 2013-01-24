class Task < ActiveRecord::Base
  STATUS = ['new', 'work', 'finish', 'cancel'].freeze
  attr_accessible :user_id, :body, :start_date, :end_date, :executer, :status, :bug

  belongs_to :user
  belongs_to :executer, :foreign_key => 'executer_id', :class_name => 'User'
  validates :body, :presence => true

  scope :order_bug, order('bug DESC')
  scope :order_created, order('created_at DESC')
  scope :by_status, ->(status) { where(status: status) }
  scope :active, where(status: %w(new work))

  default_scope :order => 'id DESC'

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
  extend SearchAndSort

  define_index do

    indexes user(:login), :as => :user, :sortable => true
    indexes executer(:login), :as => :executer, :sortable => true
    indexes body, :sortable => true
    indexes status, :sortable => true

    has :id
    has :user_id
    has :executer_id
    has :bug, :type => :boolean
    has :created_at, :start_date, :end_date, :type => :datetime
    has "CRC32(status)", :as => :status_crc32, :type => :integer
  end
end