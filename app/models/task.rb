# -*- encoding : utf-8 -*-
class Task < ActiveRecord::Base
  STATUS = [ 'new','work','cancel','finish' ].freeze
  attr_accessible :user_id, :body, :start_date, :end_date, :executer_id, :executer, :status, :bug, :comment, :image, :company_id

  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :company
  belongs_to :executer, :foreign_key => 'executer_id', :class_name => 'User'
  has_many :emails, class_name: 'UserMailer'
  validates :body, :presence => true
  validates :executer, :presence => true, :if => proc { |task| task.status != 'new' }
  validates :image, :file_size => { :maximum => CONFIG[:max_image_size].megabytes.to_i }

  scope :order_bug, order('bug DESC')
  scope :order_created, order('created_at DESC')
  scope :by_status, ->(status) { where(status: status) }
  scope :active, where(status: %w(new work))

  scope :with_columns, ->(apply_includes = false) do
    scope = joins("LEFT JOIN companies ON companies.id = tasks.company_id")
      .joins("LEFT JOIN users ON users.id = tasks.user_id")
      .joins("LEFT JOIN users as executers ON executers.id = tasks.executer_id")
      .select(['tasks.*', 'companies.name as company_name', 'users.email as user_email',
        "regexp_replace((users.last_name || ' ' || users.first_name || ' ' || users.middle_name), E'\\s+', ' ', 'g') as user_name",
        "regexp_replace((executers.last_name || ' ' || executers.first_name || ' ' || executers.middle_name), E'\\s+', ' ', 'g') as executer_name"])
  end

  extend SearchAndSort

  define_index do
    indexes [user(:last_name), user(:first_name), user(:middle_name)], as: :user_name, sortable: true
    indexes user(:email), as: :user_email, sortable: true
    indexes executer(:login), as: :executer, sortable: true
    indexes [executer(:last_name), executer(:first_name), executer(:middle_name)], as: :executer_name, sortable: true
    indexes company(:name), as: :company_name, sortable: true
    indexes body, comment, status, sortable: true

    has :id
    has :user_id
    has :company_id
    has :executer_id
    has :bug, type: :boolean
    has :created_at, :start_date, :end_date, type: :datetime
    has "CRC32(status)", :as => :status_crc32, type: :integer

    set_property :delta => true
  end

  define_index 'to_no_admin' do
    indexes body, status, sortable: true
    has :id
    has :user_id
    has :start_date, :end_date, type: :datetime
    has "CRC32(status)", :as => :status_crc32, type: :integer
  end

  state_machine :status, initial: :new do
    event :new do
      transition all => :new
    end
    event :work do
      transition all => :work
    end
    event :finish do
      transition all => :finish
    end
    event :cancel do
      transition all => :cancel
    end

    before_transition on: :work do |task, transition|
      executer = transition.args.first # the first argument for event must be a user
      attrs = transition.args[1] || {} # the second argument might be a hash of attributes
      task.assign_attributes({ executer: executer, start_date: Time.zone.now, end_date: nil }.merge!(attrs))
      task.valid?
    end
    before_transition on: [:finish, :cancel] do |task, transition|
      executer = transition.args.first # the first argument for event must be a user
      attrs = transition.args[1] || {} # the second argument might be a hash of attributes
      task.assign_attributes({ executer: executer, end_date: Time.zone.now }.merge!(attrs))
      task.valid?
    end

    after_transition any => any do |task, transition|
      Mailer.task_info(task).deliver
    end
  end
end
