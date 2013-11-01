# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Operators:", js: true do
  include ActionView::Helpers
  include OperatorsHelper

  clean_once do
    before(:all) do
      @boss = create_user_with_company_and_office :boss
    end

    let(:operator) { create(:operator, company: @boss.company) }

    before { login_as @boss }
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

    describe "actions with common operator" do
      context "synchronize" do
        let(:operator) { create :operator, company: @boss.company, updated_at: 2.days.ago }
        let(:common_operator) do
          create :common_operator, register_number: operator.register_number, register_series: operator.register_series
        end
        before do
          common_operator
          visit edit_operator_path(operator)
        end

        it 'with persisted common operator' do
          should have_content I18n.t('operators.edit.edit_operator', operator: operator.name)
          should have_content I18n.t('operators.edit.sync_proposition', common_operator: common_operator.name, operator: operator.name)
          click_link I18n.t('operators.edit.sync')
          page.current_path.should == edit_operator_path(operator)
          should have_content I18n.t('operators.edit.synced_suggestion', common_operator: common_operator.name, operator: operator.name)
          find_field('operator[inn]').value.should == common_operator.inn
          expect {
            click_link I18n.t('save')
            operator.reload
          }.to change(operator, :inn).from(operator.inn).to(common_operator.inn)
        end
      end

      context "create" do
        let(:common_operator) { create :common_operator }
        before { visit edit_operator_path(common_operator) }
        it 'company operator from common operator' do
          should have_content I18n.t('operators.edit.common_operator', operator: common_operator.name)
          should have_content I18n.t('operators.edit.common_operator_info')
          expect {
            click_link I18n.t('operators.edit.create_own')
          }.to change(Operator, :count).by(1)
          operator = Operator.where(register_number: common_operator.register_number, register_series: common_operator.register_series).last
          page.current_path.should == edit_operator_path(operator)
          find_field('operator[inn]').value.should == common_operator.inn
        end
      end
    end

  end
end
