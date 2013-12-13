# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Claim:", js: true do
  include ActionView::Helpers

  clean_once_with_sphinx do # database cleaning will excute only once after this block
    before(:all) do
      create(:user, login: 'demo')
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
        @claims = create_list(:claim, 3, company: @company, office: @office)
      end
      after(:all) { @claims.each{ |c| c.destroy } }

      before(:each) do
        visit claims_path
      end

      it "should redirect to claim_path if page number too big" do
        visit claims_path(:page => 100000)
        current_url.should == current_host + ":" + current_port.to_s + claims_path
      end

      it "should redirect to true page" do
        visit claims_path(:page => 1)
        current_url.should == current_host + ":" + current_port.to_s + claims_path(:page => 1)
      end
    end

    describe "Flight Block" do
      before do
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss)
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
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss)
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
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss)
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
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss)
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

    describe "Claim docs save" do
      before do
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss, visa_count: 1,
         children_visa_count: 1, fuel_tax_count: 1, fuel_tax_price: 1, insurance_price: 1, additional_insurance_price:1)
      end

      it "should edit and save on disk claim act" do
        @path = "uploads/#{@claim.company.id}/claims/#{@claim.id}/act.html"
        if File.exist?(@path)
          FileUtils.rm(@path)
        end
        visit(edit_claim_printers_path(claim_id: @claim.id, printer: 'act'))
        click_link I18n.t('claim_printers.edit.edit_doc')
        File.exist?(@path).should == false
        click_link I18n.t('save')
        wait_until { File.exist?(@path) == true }
        File.exist?(@path).should == true

        # page.should have_selector("div#cke_edit_content")
       # page.should have_selector("div#content")
      #  I18n.t('claim_printers.edit.edit_doc')
      #  @link = all('a').select {|elt| elt.text == I18n.t('layouts.main_menu.claims.act') }.last
     #   Rails.logger.debug "url_for_current_company: #{@link['href']}"
      #  expect {
     #     @link.click
      #  }.to change{current_path}.from(edit_claim_path(@claim)).to('/claim_print/1/act')
      #  current_path.should == @link['href']

      end
    end

    describe "Claim docs save" do
      before do
        @claim = FactoryGirl.create(:claim, company: @company, office: @office, user: @boss, visa_count: 1,
         children_visa_count: 1, fuel_tax_count: 1, fuel_tax_price: 1, insurance_price: 1, additional_insurance_price:1)
      end

      it "should edit and save on disk claim act" do
        @path = "uploads/#{@claim.company.id}/claims/#{@claim.id}/act.html"
        if File.exist?(@path)
          FileUtils.rm(@path)
        end
        visit(edit_claim_printers_path(claim_id: @claim.id, printer: 'act'))
        click_link I18n.t('claim_printers.edit.edit_doc')
        File.exist?(@path).should == false
        click_link I18n.t('save')
        wait_until { File.exist?(@path) == true }
        File.exist?(@path).should == true

        # page.should have_selector("div#cke_edit_content")
       # page.should have_selector("div#content")
      #  I18n.t('claim_printers.edit.edit_doc')
      #  @link = all('a').select {|elt| elt.text == I18n.t('layouts.main_menu.claims.act') }.last
     #   Rails.logger.debug "url_for_current_company: #{@link['href']}"
      #  expect {
     #     @link.click
      #  }.to change{current_path}.from(edit_claim_path(@claim)).to('/claim_print/1/act')
      #  current_path.should == @link['href']

      end
    end

    describe "New claim in modal form" do
      def wait_for_ajax
        Timeout.timeout(Capybara.default_wait_time) do
          loop do
            active = page.evaluate_script('jQuery.active')
            break if active == 0
          end
        end
      end

      before do
        @claim_attrs = attributes_for(:claim)
        FactoryGirl.create(:dropdown_value, company: @company, list: 'tourist_stat', value: 'test')
        Rails.logger.debug "url_for: #{@claim_attrs.inspect}"
      end

      it "should create an claim" do
        visit claims_path
        click_link I18n.t('claims.index.add_claim')
        wait_for_ajax
        page.execute_script("$('#claim_tourist_stat').ikSelect('select', 'test');")
        fill_in "claim[applicant_attributes][full_name]", :with => "#{@claim_attrs[:applicant][:first_name]} #{@claim_attrs[:applicant][:last_name]}"
        fill_in "claim[applicant_attributes][date_of_birth]", :with => l(@claim_attrs[:applicant][:date_of_birth], :format => :long)
        fill_in "claim[applicant_attributes][passport_series]", :with => "#{@claim_attrs[:applicant][:passport_series]}"
        fill_in "claim[applicant_attributes][passport_number]", :with => "#{@claim_attrs[:applicant][:passport_number]}"
        fill_in "claim[applicant_attributes][passport_valid_until]", :with => l(@claim_attrs[:applicant][:passport_valid_until], :format => :long)
        fill_in "claim[applicant_attributes][phone_number]", :with => "#{@claim_attrs[:applicant][:phone_number]}"
        fill_in "claim[applicant_attributes][email]", :with => "#{@claim_attrs[:applicant][:email]}"
        fill_in "claim[applicant_attributes][address]", :with => "Elm street"
        fill_in "claim[arrival_date]", :with => l(@claim_attrs[:arrival_date], :format => :long)
        fill_in "claim[check_date]", :with => l(@claim_attrs[:check_date], :format => :long)

        expect {
          find('#modal_claim_save').click
          wait_for_ajax
        }.to change(Claim, :count).by(1)
      end
    end

  end

end