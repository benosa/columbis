# -*- encoding : utf-8 -*-
require 'spec_helper'
  
describe "Country:", js: true do
  include ActionView::Helpers
  
  subject { page }

  before do
    @company_one = FactoryGirl.create(:company)
    @countries = []
    3.times { @countries << FactoryGirl.create(:country, :company_id => @company_one.id) }
    3.times { @countries << FactoryGirl.create(:open_country) }
    @boss       = FactoryGirl.create(:boss, :company_id => @company_one.id)
    login_as @boss
  end #create test data and login by boss

  describe "countries list" do
    clean_once_with_sphinx do

      def take_elements
        elements = []

        (2..7).to_a.each do |i|
          elements << page.find(:xpath, "//table/tbody/tr[#{i}]/td[1]/p").text.first
        end
        elements
      end #this method return string array from first column

      def sort_countries_asc_by (column)
        @countries
          .sort{|x,y| x.try(column) <=> y.try(column) }
          .map{|u| u.try(column).first }
      end

      def sort_countries_desc_by (column)
        @countries
          .sort{|x,y| y.try(column) <=> x.try(column) }
          .map{|u| u.try(column).first }
      end

      before do
        visit countries_path
      end

      it "should sort by column name" do
        # It's checking by first characters, becouse sorts in the test 
        # and sort on the page may a little different
        page.should have_selector("a.sort_active.asc[data-sort='name']")
        take_elements.should == sort_countries_asc_by(:name)
        page.find("a[data-sort='name']").click
        page.should have_selector("a.sort_active.desc[data-sort='name']")
        take_elements.should == sort_countries_desc_by(:name)
      end

      it "should filter sotring" do
        filter = @countries.first.try(:name).split(/[\s,.']/).first
        fill_in('filter', with: filter)
        @countries.each do |country|
          if country.try(:name).index(filter)
            page.has_content?(country.try(:name)).should be_true
          else
            page.has_no_content?(country.try(:name)).should be_true
          end
        end
      end
    end
  end

  describe "create country" do
    before do
      visit new_country_path
    end

    it "without name should not valid" do
      expect {
          page.fill_in "country[name]", with: ""
          page.click_link I18n.t('save')
        }.to_not change(Country, :count).by(1)
    end

    it "with name should valid" do
      expect {
          page.fill_in "country[name]", with: "Russia"
          page.click_link I18n.t('save')
        }.to change(Country, :count).by(1)
    end
  end

  describe "update country" do
    before do
      visit countries_path
      @country = @countries.find(:company_id => @boss.company_id).first
    end

    it "should not valid without empty name" do
      click_link "edit_country_#{@country.id}"
      current_path.should eq edit_country_path(@country.id)
      expect {
        fill_in "country[name]", with: ""
        click_link I18n.t('save')
        @country.reload
      }.to_not change(@country, :name).from(@country.name).to('')
      current_path.should eq country_path(@country.id)
      page.should have_selector("div.error_messages")
    end

    it 'should edit a country, redirect to countries_path' do
      click_link "edit_country_#{@country.id}"
      current_path.should eq edit_country_path(@country.id)
      expect {
        fill_in "country[name]", with: "Russia Russia"
        click_link I18n.t('save')
        @country.reload
      }.to change(@country, :name).from(@country.name).to('Russia Russia')
    end
  end

  describe "delete country" do

    before do
      visit countries_path
      @country = @countries.find(:company_id => @boss.company_id).first
    end

    it 'should valid' do
      expect{
        click_link "delete__#{@country.id}"
      }.to change(Country, :count).by(-1)
    end
  end
end