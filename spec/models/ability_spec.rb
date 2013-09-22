# -*- encoding : utf-8 -*-
require "cancan/matchers"
require 'spec_helper'

describe "Abilities for" do
  before(:all) do
    @admin = create_user_with_company_and_office(:admin)
    @another_user = create_user_with_company_and_office(:admin)
    @boss = FactoryGirl.create(:boss, :company => @admin.company, :office => @admin.office)
    @accountant = FactoryGirl.create(:accountant, :company => @admin.company, :office => @admin.office)
    @supervisor = FactoryGirl.create(:supervisor, :company => @admin.company, :office => @admin.office)
    @manager = FactoryGirl.create(:manager, :company => @admin.company, :office => @admin.office)
    @another_office = FactoryGirl.create(:office, :company => @admin.company)
  end

  subject(:ability){ Ability.new(user) }

  let(:user) { nil }
  let(:company) { @admin.company }
  let(:office) { @admin.office }
  let(:another_office) { @another_office }
  let(:another_company) { @another_user.company }
  let(:another_user) { @another_user }

  describe "companies" do
    let(:resource) { company }
    let(:unresource) { another_company }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "addresses" do
    let(:resource) { FactoryGirl.create(:address, :company => company) }
    let(:unresource) { FactoryGirl.create(:address, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "catalogs" do
    let(:resource) { FactoryGirl.create(:catalog, :company => company) }
    let(:unresource) { FactoryGirl.create(:catalog, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  # describe "clients" do
  #   let(:resource) { FactoryGirl.create(:client, :company => company) }
  #   let(:unresource) { FactoryGirl.create(:client, :company => another_company) }
  #   context "when user is admin" do
  #     let(:user){ @admin }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ should      be_able_to(:manage, unresource) }
  #   end

  #   context "when user is boss" do
  #     let(:user){ @boss }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is accountant" do
  #     let(:user){ @accountant }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is supervisor" do
  #     let(:user){ @supervisor }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is manager" do
  #     let(:user){ @manager }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end
  # end

  describe "currency courses" do
    let(:resource) { FactoryGirl.create(:currency_course, :user => user, :company => company) }
    let(:unresource) { FactoryGirl.create(:currency_course, :user => another_user, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  # describe "flights" do
  #   let(:resource) { FactoryGirl.create(:catalog, :company => company) }
  #   let(:unresource) { FactoryGirl.create(:catalog, :company => another_company) }
  #   context "when user is admin" do
  #     let(:user){ @admin }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ should      be_able_to(:manage, unresource) }
  #   end

  #   context "when user is boss" do
  #     let(:user){ @boss }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is accountant" do
  #     let(:user){ @accountant }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is supervisor" do
  #     let(:user){ @supervisor }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is manager" do
  #     let(:user){ @manager }
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end
  # end

  describe "items" do
    let(:resource) { FactoryGirl.create(:item, :company => company) }
    let(:unresource) { FactoryGirl.create(:item, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "item_fields" do
    let(:resource) { FactoryGirl.create(:item_field, :company => company) }
    let(:unresource) { FactoryGirl.create(:item_field, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "notes" do
    let(:resource) { FactoryGirl.create(:note, :company => company) }
    let(:unresource) { FactoryGirl.create(:note, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "offices" do
    let(:resource) { office }
    let(:unresource) { another_office }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "printers" do
    let(:resource) { FactoryGirl.create(:printer, :company => company) }
    let(:unresource) { FactoryGirl.create(:printer, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "widget" do
    let(:resource) { FactoryGirl.create(:widget, :company => company) }
    let(:unresource) { FactoryGirl.create(:widget, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "cities" do
    let(:resource) { FactoryGirl.create(:city, :company => company) }
    let(:ourresource) { FactoryGirl.create(:open_city) }
    let(:unresource) { FactoryGirl.create(:city, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, ourresource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  describe "countries" do
    let(:resource) { FactoryGirl.create(:country, :company => company) }
    let(:ourresource) { FactoryGirl.create(:open_country) }
    let(:unresource) { FactoryGirl.create(:country, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should      be_able_to(:manage, resource) }
      it{ should      be_able_to(:manage, ourresource) }
      it{ should      be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should      be_able_to(:manage, resource) }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
      it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
      it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
    end
  end

  # describe "dropdown values" do
  #   let(:resource) { FactoryGirl.create(:dropdown_value, :company => company) }
  #   let(:ourresource) { FactoryGirl.create(:open_dropdown_value) }
  #   let(:unresource) { FactoryGirl.create(:dropdown_value, :company => another_company) }
  #   context "when user is admin" do
  #     let(:user){ @admin }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ should      be_able_to(:manage, ourresource) }
  #     it{ should      be_able_to(:manage, unresource) }
  #   end

  #   context "when user is boss" do
  #     let(:user){ @boss }
  #     it{ should      be_able_to(:manage, resource) }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is accountant" do
  #     let(:user){ @accountant }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is supervisor" do
  #     let(:user){ @supervisor }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end

  #   context "when user is manager" do
  #     let(:user){ @manager }
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => resource)}
  #     it{ user.should have_ability({:read => true, :edit => false, :destroy => false, :update => false}, :for => ourresource)}
  #     it{ user.should have_ability({:read => false, :edit => false, :destroy => false, :update => false}, :for => unresource)}
  #   end
  # end
end