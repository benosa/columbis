class SetCanceledInPayments < ActiveRecord::Migration
  class Claim < ActiveRecord::Base
    has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }
    has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }
  end
  class Payment < ActiveRecord::Base
    belongs_to :claim
  end

  def up
    Claim.select(:id).where(canceled: true).includes(:payments_in, :payments_out).find_each(:batch_size => 500) do |claim|
      payment_ids = claim.payments_in.map(&:id)
      payment_ids += claim.payments_out.map(&:id)
      payment_ids = payment_ids.uniq.compact
      Payment.update_all({ canceled: true }, { id:  payment_ids}) unless payment_ids.empty?
    end
  end

  def down
    Claim.select(:id).where(canceled: true).includes(:payments_in, :payments_out).find_each(:batch_size => 500) do |claim|
      payment_ids = claim.payments_in.map(&:id)
      payment_ids += claim.payments_out.map(&:id)
      payment_ids = payment_ids.uniq.compact
      Payment.update_all({ canceled: false }, { id:  payment_ids}) unless payment_ids.empty?
    end
  end
end
