# -*- encoding : utf-8 -*-
class Office < ActiveRecord::Base
  attr_accessible :name, :default_password
  attr_protected :company_id

  belongs_to :company
  has_many :users
  has_many :claims

  validates_uniqueness_of :name, :scope => :company_id
  validates_presence_of :name

  before_destroy :check_assignments

  after_create do |user|
    Mailer.office_was_created(self).deliver
  end

  private

  def check_assignments
    self.errors.add(:base, I18n.t('activerecord.errors.messages.has_assignments')) unless self.users.empty?
    self.users.empty?
  end
end
