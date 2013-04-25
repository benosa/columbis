# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Operators:", js: true do
  include ActionView::Helpers
  include OperatorsHelper

  before {
    admin = FactoryGirl.create(:admin)
    visit new_user_session_path
    fill_in "user[login]", :with => admin.login
    fill_in "user[password]", :with => admin.password
    page.click_button 'user_session_submit'
    admin }
  subject { page }
  
  describe "submit form" do

    before do
      visit '/operators/new'
    end

    describe "create operator" do
      let(:operator_attrs) { attributes_for(:operator) }
      context "when invalid attribute values" do
        it "should not create an operator, should show error message" do
          expect {
            page.fill_in "operator[name]", with: ""
            page.click_link I18n.t('save')
          }.to_not change(Operator, :count)
          page.current_path.should eq(operators_path)
          page.should have_selector("div.error_messages")
        end
      end

      context "when invalid attribute values" do
        it "should create an operator, redirect to operators_path" do
          expect {
            page.fill_in "operator[name]", with: "TEST"
            page.click_link I18n.t('save')
          }.to change(Operator, :count).by(1)
          page.current_path.should eq(operators_path)
        end
      end
    end
  end


  describe "update operator" do 
    let(:operator) { create(:operator) }

    before do
      operator
      visit operators_path
    end

    it 'should not create an operator, should show error message' do
      click_link "edit_operator_#{operator.id}"
      current_path.should eq("/operators/#{operator.id}/edit")

      expect {
        fill_in "operator[name]", with: ""
        click_link I18n.t('save')
      }.to_not change(operator, :name).from(operator.name).to('')
      current_path.should eq("/operators/#{operator.id}")
      page.should have_selector("div.error_messages")
    end

    it 'should edit an operator, redirect to operators_path' do
      click_link "edit_operator_#{operator.id}"
      current_path.should eq("/operators/#{operator.id}/edit")

      expect {
        fill_in "operator[name]", with: "qweqwe" 
        click_link I18n.t('save')
        operator.reload
      }.to change(operator, :name).from(operator.name).to('qweqwe')
      operator.name.should eq("qweqwe")
      current_path.should eq(operators_path)
    end

    it 'delete operator, edit operator' do
      click_link "edit_operator_#{operator.id}"
      current_path.should eq("/operators/#{operator.id}/edit")
      expect{
        click_link I18n.t('delete')
      }.to change(Operator, :count).by(-1)
    end
  end

  describe "delete operator" do 
    let(:operator) { create(:operator) }
    before do
      operator
      visit operators_path
    end
    it 'delete operator' do
      expect{
        click_link "delete_operator_#{operator.id}"
      }.to change(Operator, :count).by(-1)
    end
  end
end
