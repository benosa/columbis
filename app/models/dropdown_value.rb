class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  validates_presence_of :list, :value

  def self.method_missing(meth, *args, &block)
    if meth.to_s =~ /^dd_for_(.+)$/
      DropdownValue.where( :list => $1 )
    elsif meth.to_s =~ /^values_for_(.+)$/
      DropdownValue.where( :list => $1 ).map &:value
    else
      super
    end
  end
end
