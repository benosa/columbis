require 'spec_helper'

describe "TariffPlans", js: true do
  include ActionView::Helpers
  before(:all) do
    @admin = login_as_admin
  end

  before do
    login_as @admin
  end

  describe 'index view' do
    before(:all) do
      FactoryGirl.create(:tariff_plan)
    end

    before do
      visit tariff_plans_path
    end

    it 'should content table with tarrif plan' do
      all('#content.content table tr').length.should == TariffPlan.all.length + 1
    end

    it 'should content delete button and click on it have been destroy tarrif plan' do
      expect {
        all('.delete').first.click
      }.to change(TariffPlan, :count).by(-1)
    end

    it 'should content edit button and click on it have been redirect to edit page' do
      e = all('.edit_row').first
      id = e['href'].split('/')
      id = id[id.length-2]
      e.click
      current_path.should == edit_tariff_plan_path(id)
    end

    it 'should content new button and click on it have been redirect to new page' do
      find('a.add_operator').click
      current_path.should == new_tariff_plan_path
    end
  end

  describe 'new view' do
    let(:tariff_plan_attrs) { attributes_for(:tariff_plan) }
    before do
      visit new_tariff_plan_path
    end
    it 'should save new tarrif plan with valid params' do
      fill_in 'tariff_plan_name', :with => tariff_plan_attrs['name']
      fill_in 'tariff_plan_price', :with => tariff_plan_attrs['price']
      fill_in 'tariff_plan_users_count', :with => tariff_plan_attrs['users_count']
      fill_in 'tariff_plan_place_size', :with => tariff_plan_attrs['place_size']
      find('a.save').click
      TariffPlan.last.name == tariff_plan_attrs['name']
      TariffPlan.last.price == tariff_plan_attrs['price']
      TariffPlan.last.users_count == tariff_plan_attrs['users_count']
      TariffPlan.last.place_size == tariff_plan_attrs['place_size']
    end
    it 'should not save tarrif plan with invalid params' do
      length = TariffPlan.all.length
      fill_in 'tariff_plan_name', :with => ''
      fill_in 'tariff_plan_price', :with => 'invalid'
      fill_in 'tariff_plan_users_count', :with => 'invalid'
      fill_in 'tariff_plan_place_size', :with => 'invalid'
      find('a.save').click
      TariffPlan.all.length.should == length
    end
  end

  describe 'edit view' do
    let(:tariff_plan_attrs) { attributes_for(:tariff_plan) }
    before do
      visit edit_tariff_plan_path(TariffPlan.first.id)
    end

    it 'should edit tarrif plan with valid params' do
      fill_in 'tariff_plan_name', :with => tariff_plan_attrs['name']
      fill_in 'tariff_plan_price', :with => tariff_plan_attrs['price']
      fill_in 'tariff_plan_users_count', :with => tariff_plan_attrs['users_count']
      fill_in 'tariff_plan_place_size', :with => tariff_plan_attrs['place_size']
      find('a.save').click
      TariffPlan.first.name == tariff_plan_attrs['name']
      TariffPlan.first.price == tariff_plan_attrs['price']
      TariffPlan.first.users_count == tariff_plan_attrs['users_count']
      TariffPlan.first.place_size == tariff_plan_attrs['place_size']
    end
    it 'should not edit tarrif plan with invalid params' do
      fill_in 'tariff_plan_name', :with => ''
      fill_in 'tariff_plan_price', :with => 'invalid'
      fill_in 'tariff_plan_users_count', :with => 'invalid'
      fill_in 'tariff_plan_place_size', :with => 'invalid'
      find('a.save').click
      current_path.should == tariff_plan_path(TariffPlan.first.id)
    end
  end
end