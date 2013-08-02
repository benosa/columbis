# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Claim:", js: true do
  include ActionView::Helpers

  before do
    @company = FactoryGirl.create(:company)
    @office = FactoryGirl.create(:office, :company_id => @company.id)
    @boss    = FactoryGirl.create(:boss, :company_id => @company.id, :office_id => @office.id)
    login_as @boss
  end

  describe "Flight Block" do
    before do
      @claim = FactoryGirl.create(:claim, user_id: @boss.id, office_id: @office.id, company_id: @company.id)
    end

    def add_flights_to_page(count = 2)
      count.times do
        find('a#add_flight').click
      end
    end

    it "should not be nil in new claim" do
      visit new_claim_path
      all('div#flights div.form_block_content div.fields').should_not be_nil
      all('div#flights div.form_block_content div.fields').length.should == 2
    end

    it "should not be nil if have been saving errors" do
      visit new_claim_path
      all("a.save[data-submit='new_claim']").first.click
      all('div#flights div.form_block_content div.fields').should_not be_nil
      all('div#flights div.form_block_content div.fields').length.should == 2
    end

    it "should add new flights and save all" do
      visit(edit_claim_path(@claim))
      add_flights_to_page(5)
      selects = all('div#flights div.form_block_content div.fields')
      selects.each_with_index do |field, i|
        fill_in "claim[flights_attributes][#{i}][airport_from]", :with => "airport_from#{i}"
        fill_in "claim[flights_attributes][#{i}][depart]", :with => "01.01.2013 00:00"
        fill_in "claim[flights_attributes][#{i}][flight_number]", :with => "123"
        fill_in "claim[flights_attributes][#{i}][airport_to]", :with => "airport_to"
        fill_in "claim[flights_attributes][#{i}][arrive]", :with => "01.01.2013 00:00"
      end
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      selects = all('div#flights div.form_block_content div.fields')
      selects.each_with_index do |field, i|
        find("input[name='claim[flights_attributes][#{i}][airport_from]']").value.should == "airport_from#{i}"
        find("input[name='claim[flights_attributes][#{i}][depart]']").value.should == "01.01.2013 00:00"
        find("input[name='claim[flights_attributes][#{i}][flight_number]']").value.should == "123"
        find("input[name='claim[flights_attributes][#{i}][airport_to]']").value.should == "airport_to"
        find("input[name='claim[flights_attributes][#{i}][arrive]']").value.should == "01.01.2013 00:00"
      end
    end

    it "should delete flights but first two flights must clear" do
      visit(edit_claim_path(@claim))
      add_flights_to_page(5)
      selects = all('div#flights div.form_block_content div.fields')
      selects.each_with_index do |field, i|
        fill_in "claim[flights_attributes][#{i}][airport_from]", :with => "airport_from#{i}"
        fill_in "claim[flights_attributes][#{i}][depart]", :with => "01.01.2013 00:00"
        fill_in "claim[flights_attributes][#{i}][flight_number]", :with => "123"
        fill_in "claim[flights_attributes][#{i}][airport_to]", :with => "airport_to"
        fill_in "claim[flights_attributes][#{i}][arrive]", :with => "01.01.2013 00:00"
        field.find("a.delete").click
      end
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      selects = all('div#flights div.form_block_content div.fields')
      selects.length.should == 2
      selects.each_with_index do |field, i|
        find("input[name='claim[flights_attributes][#{i}][airport_from]']").value.should == ""
        find("input[name='claim[flights_attributes][#{i}][depart]']").value.should == ""
        find("input[name='claim[flights_attributes][#{i}][flight_number]']").value.should == ""
        find("input[name='claim[flights_attributes][#{i}][airport_to]']").value.should == ""
        find("input[name='claim[flights_attributes][#{i}][arrive]']").value.should == ""
      end
    end
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
      old_checkbox = find('#claim_special_offer')['checked']
      find('#special_offer_checkbox').click
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      find('#claim_special_offer')['checked'].should == !old_checkbox
      old_checkbox = find('#claim_special_offer')['checked']
      find('#special_offer_checkbox').click
      all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
      visit(edit_claim_path(@claim))
      find('#claim_special_offer')['checked'].should == !old_checkbox
    end
  end

end