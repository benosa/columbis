# -*- encoding : utf-8 -*-
require 'spec_helper'
  
describe "City:", js: true do
  include ActionView::Helpers
  
  subject { page }

  before do
    @cities = []
    @company_one = FactoryGirl.create(:company)
    @boss    = FactoryGirl.create(:boss, :company_id => @company_one.id)
    @country = FactoryGirl.create(:country, :company_id => @boss.company_id)
    3.times { @cities << FactoryGirl.create(:city, :company_id => @boss.company_id, :country_id => @country.id) }
    3.times { @cities << FactoryGirl.create(:open_city, :country_id => @country.id) }
    login_as @boss
  end #create test data and login by boss

  describe "cities list" do
    clean_once_with_sphinx do

      before do
        visit cities_path
        @cities_for_sort = @cities.map{ |city| {:name => city.name, :country_name => city.country.name } }
      end

      def take_elements(column_number)
        elements = []

        (2..7).to_a.each do |i|
          elements << page.find(:xpath, "//table/tbody/tr[#{i}]/td[#{column_number + 1}]/p").text.first
        end
        elements
      end #this method return string array from first column

      def sort_cities_asc_by (column)
        @cities_for_sort
          .sort{|x,y| x[column] <=> y[column] }
          .map{|u| u[column].first }
      end

      def sort_cities_desc_by (column)
        @cities_for_sort
          .sort{|x,y| y[column] <=> x[column] }
          .map{|u| u[column].first }
      end

      it "should sort by column name" do
        # It's checking by first characters, because sorts in the test 
        # and sort on the page may a little different
        columns = [:name, :country_name]
        columns.each_with_index do |column, i|
          if column != :name
            page.find("a[data-sort='#{column}']").click
          end
          page.should have_selector("a.sort_active.asc[data-sort='#{column}']")
          take_elements(i).should == sort_cities_asc_by(column)
          page.find("a[data-sort='#{column}']").click
          page.should have_selector("a.sort_active.desc[data-sort='#{column}']")
          take_elements(i).should == sort_cities_desc_by(column)
        end
      end

      it "should filter sotring" do
        filter = @cities_for_sort.first[:name].split(/[\s]/).first
        fill_in('filter', with: filter)
        @cities_for_sort.each do |city|
          if city[:name].index(filter) or city[:country_name].index(filter)
            page.has_content?(city[:name]).should be_true
          else
            page.has_no_content?(city[:name]).should == true
          end
        end
      end
    end
  end

  describe "create city" do
    before do
      visit new_city_path
    end

    it "without name should not valid" do
      expect {
          page.fill_in "city[name]", with: ""
          page.click_link I18n.t('save')
        }.to_not change(City, :count).by(1)
    end

    it "with name should valid" do
      expect {
          page.fill_in "city[name]", with: "Moscow"
          page.click_link I18n.t('save')
        }.to change(City, :count).by(1)
    end
  end

  describe "update city" do
    before do
      visit cities_path
      @city = @cities.find(:company_id => @boss.company_id).first
    end

    it "should not valid without empty name" do
      click_link "edit_city_#{@city.id}"
      current_path.should eq edit_city_path(@city.id)
      expect {
        fill_in "city[name]", with: ''
        click_link I18n.t('save')
        @city.reload
      }.to_not change(@city, :name).to("")
      current_path.should eq city_path(@city.id)
      page.should have_selector("div.error_messages")
    end

    it 'should edit a city, redirect to cities_path' do
      click_link "edit_city_#{@city.id}"
      current_path.should eq edit_city_path(@city.id)
      expect {
        fill_in "city[name]", with: "Moscow Moscow"
        click_link I18n.t('save')
        @city.reload
      }.to change(@city, :name).to('Moscow Moscow')
    end
  end

  describe "delete city" do

    before do
      visit cities_path
      @city = @cities.find(:company_id => @boss.company_id).first
    end

    it 'should valid' do
      expect{
        click_link "delete__#{@city.id}"
      }.to change(City, :count).by(-1)
    end
  end

  describe "form city" do
    clean_once_with_sphinx do
      before do
        visit new_city_path
      end
      it "should create country" do
        expect {
          page.fill_in "city[name]", with: "Moscow"
          page.fill_in "city[country][name]", with: "Russia"
          page.click_link I18n.t('save')
        }.to change(Country, :count).by(1)
      end
    end
  end
end