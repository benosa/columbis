# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Claim:", js: true do
  include ActionView::Helpers

  before do
    @company = FactoryGirl.create(:company)
    @office  = FactoryGirl.create(:office, :company_id => @company.id)
    @boss    = FactoryGirl.create(:boss, :company_id => @company.id, :office_id => @office.id)
    login_as @boss
  end

  describe "Information block" do
    before do
      @claim = FactoryGirl.create(:claim, user_id: @boss.id, office_id: @office.id, company_id: @company.id)
    end

    it "should be content special_offer label-checkbox" do
      visit(edit_claim_path(@claim))
      page.should have_selector('#special_offer_checkbox')
    end

    it "should check label-checkbox and save to tourist special_offer" do
      visit(edit_claim_path(@claim))
      old_checkbox = find('#claim_special_offer_get')['checked']
      find('#special_offer_checkbox').click
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      find('#claim_special_offer_get')['checked'].should == !old_checkbox
      old_checkbox = find('#claim_special_offer_get')['checked']
      find('#special_offer_checkbox').click
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      find('#claim_special_offer_get')['checked'].should == !old_checkbox
    end
  end

end