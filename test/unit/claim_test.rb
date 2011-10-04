require 'test_helper'

class ClaimTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Claim.new.valid?
  end
end
