# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Operators:", js: true do
  include ActionView::Helpers
  include OperatorsHelper

  clean_once_with_sphinx do

    before { login_as_admin }
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
              click_link I18n.t('save')
            }.to change(Operator, :count).by(1)
            page.current_path.should eq(operator_path(Operator.last.id))
          end
        end
      end
    end
  end
end
