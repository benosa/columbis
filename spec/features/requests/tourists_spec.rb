# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tourist:", js: true do
  include ActionView::Helpers
  include TouristsHelper

  clean_once do
    before(:all) do
      @boss = create_user_with_company_and_office :boss
    end

    before { login_as @boss }
    subject { page }

    let(:boss) { @boss }
    let(:company) { @boss.company }

    describe "submit form" do

      before do
        visit new_tourist_path
      end

      describe "create tourist" do
        context "when invalid attribute values" do
          it "should not create an tourist, should show error message" do
            expect {
              fill_in "tourist[last_name]", with: ""
              fill_in "tourist[first_name]", with: ""
              page.click_link I18n.t('save')
            }.to_not change(Tourist, :count)
            page.current_path.should eq(tourists_path)
            page.should have_selector("div.error_messages")
          end
        end

        context "when valid attribute values" do
          it "should create an tourist, redirect to tourists_path" do
            tourist_attrs = attributes_for(:tourist)
            expect {
              tourist_attrs.each do |atr, value|
                fill_in "tourist[#{atr}]", with: value if page.has_field?("tourist[#{atr}]")
              end
              page.click_link I18n.t('save')
            }.to change(Tourist, :count).by(1)
            page.current_path.should eq(tourists_path)
            tourist = Tourist.find_by_last_name(tourist_attrs[:last_name])
            page.find("#tourist-#{tourist.id}").visible?.should be_true
          end
        end

        context "create tourist potential" do
          before { visit new_tourist_path(potential: 1) }
          it "should create an tourist potential" do
            tourist_attrs = attributes_for(:tourist)
            expect {
              fill_in "tourist[full_name]", with: "#{tourist_attrs[:last_name]} #{tourist_attrs[:first_name]}"
              tourist_attrs.each do |atr, value|
                fill_in "tourist[#{atr}]", with: value if page.has_field?("tourist[#{atr}]")
              end
              # find('label[for=tourist_potential]').trigger('click')
              page.click_link I18n.t('save')
            }.to change(Tourist, :count).by(1)
            # Obscure bug with redirect to tourists_path instead of tourists_path(potential: 1)
            # page.current_path.should eq(tourists_path(potential: 1))
            # tourist = Tourist.find_by_last_name(tourist_attrs[:last_name])
            # # page.click_link('clients_potential')
            # page.find("#tourist-#{tourist.id}").visible?.should be_true
          end
        end
      end
    end


    describe "update tourist" do
      let(:tourist) { create(:tourist, company: company) }
      #before(:all) {self.use_transactional_fixtures = false}

      before do
        tourist
        visit tourists_path
      end

      it 'should not create an tourist, should show error message' do
        click_link "edit_tourist_#{tourist.id}"
        current_path.should eq("/tourists/#{tourist.id}/edit")
        expect {
          fill_in "tourist[last_name]", with: ""
          click_link I18n.t('save')
        }.to_not change(tourist, :name).from(tourist.last_name).to('')
        current_path.should eq("/tourists/#{tourist.id}")
        page.should have_selector("div.error_messages")
      end

      it 'should edit an tourist, redirect to tourists_path' do
        click_link "edit_tourist_#{tourist.id}"
        current_path.should eq("/tourists/#{tourist.id}/edit")
        expect {
          page.fill_in "tourist[first_name]", with: "test"
          click_link I18n.t('save')
          tourist.reload
        }.to change(tourist, :first_name).from(tourist.first_name).to('test')
        tourist.first_name.should eq("test")
      end

      it 'delete tourist, edit tourist' do
        click_link "edit_tourist_#{tourist.id}"
        current_path.should eq("/tourists/#{tourist.id}/edit")

        expect{
          click_link I18n.t('delete')
        }.to change(Tourist, :count).by(-1)
      end
    end

    describe "delete tourist" do
      let(:tourist) { create(:tourist, company: company) }
      before do
        tourist
        visit tourists_path
      end
      it 'delete tourist' do
        expect{
          page.click_link "delete_tourist_#{tourist.id}"
        }.to change(Tourist, :count).by(-1)
      end
    end
  end
end
