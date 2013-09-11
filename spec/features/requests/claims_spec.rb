# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Claim:", js: true do
  include ActionView::Helpers

  clean_once_with_sphinx do # database cleaning will excute only once after this block
    before(:all) do
      @boss = create_user_with_company_and_office(:boss)
      @company = @boss.company
      @office = @boss.office
    end
    before do
      login_as @boss
    end

    subject { page }

    describe "Pagination" do
      before(:all) do
        create_claims_with_prerequisites(@company, :claim, 10)
      end

      before(:each) do
        visit claims_path
      end

      it "should redirect to claim_path if page number too big" do
        visit claims_path(:page => 100000)
        current_url.should == current_host + ":" + current_port + claims_path
      end

      it "should redirect to true page" do
        visit claims_path(:page => 1)
        current_url.should == current_host + ":" + current_port + claims_path(:page => 1)
      end
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

    describe "num_column" do
      before do
        @claim = FactoryGirl.build(:claim, company_id: @company.id)
        @claim.num = 321123
        @claim.save
      end

      it "should be link with content 321123" do
        visit claims_path
        page.should have_selector('a.id_link', :text => '321123')
      end
    end

    describe "Locking" do
      before do
        @claim = FactoryGirl.create(:claim, user_id: @boss.id, office_id: @office.id, company_id: @company.id)
      end

      it "should be edited and locked" do
        visit(edit_claim_path(@claim))
        fill_in_with_trigger "claim_operator_confirmation", :with => "6E-154600652" # trigger change event and lock request
        expect { page.evaluate_script("$('.edit_claim').data('changed');") }.to become_true
        find('#content .top h1').text.should have_content(I18n.t('claims.messages.locked'))
        @claim.reload
        @claim.edited?.should be_true
        @claim.locked_by.should == @boss.id
      end

      it "should check locking and saving" do
        visit(edit_claim_path(@claim))
        expect {
          fill_in "claim_operator_confirmation", :with => "6E-154600652"
          all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
          @claim.reload
        }.to change(@claim, :operator_confirmation).from(nil).to('6E-154600652')
        find("#claim_operator_confirmation").value.should == "6E-154600652"
        @claim.edited?.should be_false
        @claim.locked_by.should == nil
      end

      it "should check locked claim for error after saving" do
        @another_boss = FactoryGirl.create(:boss, company: @boss.company, office: @boss.office)
        @claim.lock(@another_boss)
        @claim.reload
        visit(edit_claim_path(@claim))
        expect {
          fill_in "claim_operator_confirmation", :with => "6E-154600652"
          all("a.save[data-submit='edit_claim_#{@claim.id}']").first.click
          @claim.reload
        }.to_not change(@claim, :operator_confirmation).from(nil).to('6E-154600652')
        page.should have_content(I18n.t('claims.messages.is_editing'))
      end
    end
  end

end