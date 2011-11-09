class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  validates_presence_of :list, :value

  def self.check_and_save(list, value)
    self.create(:list => list, :value => value) unless self.where(:list => list, :value => value).first
  end

  def self.method_missing(meth, *args, &block)
    # just returns values for certain list
    if meth.to_s =~ /^dd_for_(.+)$/
      # returns as an AR-objects array
      # for example: DropdownValue.dd_for_payment_form. where list name is 'payment_form'
      DropdownValue.where( :list => $1 )
    elsif meth.to_s =~ /^values_for_(.+)$/
      # returns as a string array
      # for example: DropdownValue.values_for_payment_form. where list name is 'payment_form'
      DropdownValue.where( :list => $1 ).map &:value
    else
      super
    end
  end
end
