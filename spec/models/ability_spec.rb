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

  after(:all) do
    DatabaseCleaner.clean_with :truncation
  end

  subject(:ability){ Ability.new(user) }

  let(:user) { nil }
  let(:company) { @admin.company }
  let(:office) { @admin.office }
  let(:another_office) { @another_office }
  let(:another_company) { @another_user.company }
  let(:another_user) { @another_user }
  let(:user_claim) { FactoryGirl.create(:claim, :company => company, :user => user, :office => office) }
  let(:assistant_claim) { FactoryGirl.create(:claim, :company => company, :assistant => user, :office => office) }

  describe "companies" do
    let(:resource) { company }
    let(:unresource) { another_company }

    context "when user is admin" do
      let(:user){ @admin }
      it{ should not_be_able_to([:create, :new, :index], Company) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should not_be_able_to([:create, :new, :index], Company) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Company) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Company) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Company) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "addresses" do
    let(:resource) { FactoryGirl.create(:address, :company => company) }
    let(:unresource) { FactoryGirl.create(:address, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Address) }
      it{ should     be_able_to(:create, Address) }
      it{ should     be_able_to(:new, Address) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Address) }
      it{ should     be_able_to(:create, Address) }
      it{ should     be_able_to(:new, Address) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Address) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Address) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Address) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "currency courses" do
    let(:resource) { FactoryGirl.create(:currency_course, :user => user, :company => company) }
    let(:unresource) { FactoryGirl.create(:currency_course, :user => another_user, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, CurrencyCourse) }
      it{ should     be_able_to(:create, CurrencyCourse) }
      it{ should     be_able_to(:new, CurrencyCourse) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, CurrencyCourse) }
      it{ should     be_able_to(:create, CurrencyCourse) }
      it{ should     be_able_to(:new, CurrencyCourse) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:index, CurrencyCourse) }
      it{ should     be_able_to(:create, CurrencyCourse) }
      it{ should     be_able_to(:new, CurrencyCourse) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], CurrencyCourse) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], CurrencyCourse) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "flights" do
    let(:resource) { FactoryGirl.create(:flight, :claim => FactoryGirl.create(:claim, :company => user.company )) }
    let(:unresource) { FactoryGirl.create(:flight) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:manage, resource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "offices" do
    let(:resource) { office }
    let(:resource2) { another_office }
    let(:unresource) { another_user.office }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Office) }
      it{ should     be_able_to(:create, Office) }
      it{ should     be_able_to(:new, Office) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, resource2) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Office) }
      it{ should     be_able_to(:create, Office) }
      it{ should     be_able_to(:new, Office) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, resource2) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Office) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, resource2)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource2)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Office) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Office) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "printers" do
    let(:resource) { FactoryGirl.create(:printer, :company => company) }
    let(:unresource) { FactoryGirl.create(:printer, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Printer) }
      it{ should     be_able_to(:create, Printer) }
      it{ should     be_able_to(:new, Printer) }
      it{ should     be_able_to(:download, Printer) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Printer) }
      it{ should     be_able_to(:create, Printer) }
      it{ should     be_able_to(:new, Printer) }
      it{ should     be_able_to(:download, Printer) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index, :download], Printer) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index, :download], Printer) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index, :download], Printer) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
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
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "cities" do
    let(:resource) { FactoryGirl.create(:city, :company => company) }
    let(:ourresource) { FactoryGirl.create(:open_city) }
    let(:unresource) { FactoryGirl.create(:city, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, City) }
      it{ should     be_able_to(:create, City) }
      it{ should     be_able_to(:new, City) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, ourresource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, City) }
      it{ should     be_able_to(:create, City) }
      it{ should     be_able_to(:new, City) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], City) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], City) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], City) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "countries" do
    let(:resource) { FactoryGirl.create(:country, :company => company) }
    let(:ourresource) { FactoryGirl.create(:open_country) }
    let(:unresource) { FactoryGirl.create(:country, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Country) }
      it{ should     be_able_to(:create, Country) }
      it{ should     be_able_to(:new, Country) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, ourresource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Country) }
      it{ should     be_able_to(:create, Country) }
      it{ should     be_able_to(:new, Country) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Country) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Country) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Country) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "dropdown values" do
    let(:resource) { FactoryGirl.create(:dropdown_value, :company_id => company.id) }
    let(:ourresource) { FactoryGirl.create(:open_dropdown_value) }
    let(:unresource) { FactoryGirl.create(:dropdown_value, :company_id => another_company.id) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, DropdownValue) }
      it{ should     be_able_to(:create, DropdownValue) }
      it{ should     be_able_to(:new, DropdownValue) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, ourresource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, DropdownValue) }
      it{ should     be_able_to(:create, DropdownValue) }
      it{ should     be_able_to(:new, DropdownValue) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], DropdownValue) }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update], resource)}
      it{ should     be_able_to(:read, ourresource)}
      it{ should not_be_able_to([:edit, :destroy, :update], ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], DropdownValue) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], DropdownValue) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, ourresource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "payment" do
    let(:resource) { FactoryGirl.create(:clientbase_payment, :company => company, :recipient => company, :date_in => Time.zone.now, :claim => user_claim) }
    let(:unresource) { FactoryGirl.create(:clientbase_payment, :company => another_company, :recipient => another_company, :date_in => Time.zone.now) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Payment) }
      it{ should     be_able_to(:create, Payment) }
      it{ should     be_able_to(:new, Payment) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Payment) }
      it{ should     be_able_to(:create, Payment) }
      it{ should     be_able_to(:new, Payment) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Payment) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Payment) }
      context "and approved = true" do
        it{ should not_be_able_to(:manage, resource)}
        it{ should not_be_able_to(:manage, unresource)}
      end
      context "and approved = false" do
        let(:resource) { FactoryGirl.create(:clientbase_payment, :company => company, :approved => false, :recipient => company, :date_in => Time.zone.now) }
        it{ should     be_able_to(:update, resource)}
        it{ should not_be_able_to([:edit, :destroy, :read, :create], resource)}
      end
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Payment) }
      context "and approved = true" do
        it{ should not_be_able_to(:manage, resource)}
        it{ should not_be_able_to(:manage, unresource)}
      end
      context "and approved = false and user who has enter" do
        let(:resource) { FactoryGirl.create(:clientbase_payment, :company => company, :approved => false, :recipient => company, :date_in => Time.zone.now, :claim => user_claim) }
        let(:resource2) { FactoryGirl.create(:clientbase_payment, :company => company, :approved => false, :recipient => company, :date_in => Time.zone.now, :claim => assistant_claim) }
        let(:unresource) { FactoryGirl.create(:clientbase_payment, :company => company, :approved => false, :recipient => company, :date_in => Time.zone.now) }
        it{ should     be_able_to(:update, resource)}
        it{ should not_be_able_to([:edit, :destroy, :read, :create], resource)}
        it{ should     be_able_to(:update, resource2)}
        it{ should not_be_able_to([:edit, :destroy, :read, :create], resource2)}
        it{ should not_be_able_to(:manage, unresource)}
      end
    end
  end

  describe "regions" do
    let(:resource) { FactoryGirl.create(:region) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:manage, resource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update, :create], resource) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update, :create], resource) }
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update, :create], resource) }
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should     be_able_to(:read, resource)}
      it{ should not_be_able_to([:edit, :destroy, :update, :create], resource) }
    end
  end

  describe "tariff plans" do
    let(:resource) { FactoryGirl.create(:tariff_plan) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, TariffPlan) }
      it{ should     be_able_to(:create, TariffPlan) }
      it{ should     be_able_to(:new, TariffPlan) }
      it{ should     be_able_to(:manage, resource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should not_be_able_to([:create, :new, :index], TariffPlan) }
      it{ should not_be_able_to(:manage, resource) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], TariffPlan) }
      it{ should not_be_able_to(:manage, resource) }
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], TariffPlan) }
      it{ should not_be_able_to(:manage, resource) }
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], TariffPlan) }
      it{ should not_be_able_to(:manage, resource) }
    end
  end

  describe "tasks" do
    let(:resource) { FactoryGirl.create(:task, :user => user) }
    let(:unresource) { FactoryGirl.create(:task, :user => another_user) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Task) }
      it{ should     be_able_to(:create, Task) }
      it{ should     be_able_to(:new, Task) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should not_be_able_to([:index], Task) }
      it{ should     be_able_to(:create, Task) }
      it{ should     be_able_to(:new, Task) }
      it{ should     be_able_to(:create, resource) }
      it{ should not_be_able_to([:read, :edit, :destroy, :update], resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:index], Task) }
      it{ should     be_able_to(:create, Task) }
      it{ should     be_able_to(:new, Task) }
      it{ should     be_able_to(:create, resource) }
      it{ should not_be_able_to([:read, :edit, :destroy, :update], resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:index], Task) }
      it{ should     be_able_to(:create, Task) }
      it{ should     be_able_to(:new, Task) }
      it{ should     be_able_to(:create, resource) }
      it{ should not_be_able_to([:read, :edit, :destroy, :update], resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:index], Task) }
      it{ should     be_able_to(:create, Task) }
      it{ should     be_able_to(:new, Task) }
      it{ should     be_able_to(:create, resource) }
      it{ should not_be_able_to([:read, :edit, :destroy, :update], resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "tourists" do
    let(:resource) { FactoryGirl.create(:tourist, :company => company) }
    let(:unresource) { FactoryGirl.create(:tourist, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Tourist) }
      it{ should     be_able_to(:create, Tourist) }
      it{ should     be_able_to(:new, Tourist) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Tourist) }
      it{ should     be_able_to(:create, Tourist) }
      it{ should     be_able_to(:new, Tourist) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:index, Tourist) }
      it{ should     be_able_to(:create, Tourist) }
      it{ should     be_able_to(:new, Tourist) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should     be_able_to(:index, Tourist) }
      it{ should     be_able_to(:create, Tourist) }
      it{ should     be_able_to(:new, Tourist) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should     be_able_to(:index, Tourist) }
      it{ should     be_able_to(:create, Tourist) }
      it{ should     be_able_to(:new, Tourist) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "user mailers" do
    let(:resource) { FactoryGirl.create(:user_mailer, :task => FactoryGirl.create(:task, :user => user)) }
    let(:unresource) { FactoryGirl.create(:user_mailer) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:read, resource) }
      it{ should not_be_able_to([:edit, :destroy, :update, :create], resource) }
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end

  describe "users" do
    let(:admin) { FactoryGirl.create(:admin, :company => company) }
    let(:boss) { FactoryGirl.create(:boss, :company => company) }
    let(:accountant) { FactoryGirl.create(:accountant, :company => company) }
    let(:supervisor) { FactoryGirl.create(:supervisor, :company => company) }
    let(:manager) { FactoryGirl.create(:manager, :company => company) }
    let(:another_office_accountant) { FactoryGirl.create(:accountant, :company => company, :office => another_office) }
    let(:another_office_supervisor) { FactoryGirl.create(:supervisor, :company => company, :office => another_office) }
    let(:another_office_manager) { FactoryGirl.create(:manager, :company => company, :office => another_office) }
    let(:another_admin) { FactoryGirl.create(:admin, :company => another_company) }
    let(:another_boss) { FactoryGirl.create(:boss, :company => another_company) }
    let(:another_accountant) { FactoryGirl.create(:accountant, :company => another_company) }
    let(:another_supervisor) { FactoryGirl.create(:supervisor, :company => another_company) }
    let(:another_manager) { FactoryGirl.create(:manager, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, User) }
      it{ should     be_able_to(:create, User) }
      it{ should     be_able_to(:new, User) }
      it{ should     be_able_to(:manage, admin) }
      it{ should     be_able_to(:manage, boss) }
      it{ should     be_able_to(:manage, accountant) }
      it{ should     be_able_to(:manage, supervisor) }
      it{ should     be_able_to(:manage, manager) }
      it{ should     be_able_to(:manage, another_office_accountant) }
      it{ should     be_able_to(:manage, another_office_supervisor) }
      it{ should     be_able_to(:manage, another_office_manager) }
      it{ should     be_able_to(:manage, another_admin) }
      it{ should     be_able_to(:manage, another_boss) }
      it{ should     be_able_to(:manage, another_accountant) }
      it{ should     be_able_to(:manage, another_supervisor) }
      it{ should     be_able_to(:manage, another_manager) }
      it{ should     be_able_to(:offline_version, User) }
      it{ should     be_able_to(:switch_view, User) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, User) }
      it{ should     be_able_to(:create, User) }
      it{ should     be_able_to(:new, User) }
      it{ should not_be_able_to(:manage, admin) }
      it{ should     be_able_to(:manage, boss) }
      it{ should     be_able_to(:manage, accountant) }
      it{ should     be_able_to(:manage, supervisor) }
      it{ should     be_able_to(:manage, manager) }
      it{ should     be_able_to(:manage, another_office_accountant) }
      it{ should     be_able_to(:manage, another_office_supervisor) }
      it{ should     be_able_to(:manage, another_office_manager) }
      it{ should not_be_able_to(:manage, another_admin) }
      it{ should not_be_able_to(:manage, another_boss) }
      it{ should not_be_able_to(:manage, another_accountant) }
      it{ should not_be_able_to(:manage, another_supervisor) }
      it{ should not_be_able_to(:manage, another_manager) }
      it{ should     be_able_to(:offline_version, User) }
      it{ should     be_able_to(:switch_view, User) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], User) }
      it{ should not_be_able_to(:manage, admin) }
      it{ should     be_able_to(:update, @accountant) }
      it{ should     be_able_to(:destroy, @accountant) }
      it{ should not_be_able_to([:read, :edit, :create], @accountant) }
      it{ should     be_able_to(:read, boss) }
      it{ should     be_able_to(:read, accountant) }
      it{ should     be_able_to(:read, supervisor) }
      it{ should     be_able_to(:read, manager) }
      it{ should     be_able_to(:read, another_office_accountant) }
      it{ should     be_able_to(:read, another_office_supervisor) }
      it{ should     be_able_to(:read, another_office_manager) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], boss) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], accountant) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], supervisor) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], manager) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], another_office_accountant) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], another_office_supervisor) }
      it{ should not_be_able_to([:edit, :destroy, :create, :update], another_office_manager) }
      it{ should not_be_able_to(:manage, another_admin) }
      it{ should not_be_able_to(:manage, another_boss) }
      it{ should not_be_able_to(:manage, another_accountant) }
      it{ should not_be_able_to(:manage, another_supervisor) }
      it{ should not_be_able_to(:manage, another_manager) }
      it{ should     be_able_to(:offline_version, User) }
      it{ should     be_able_to(:switch_view, User) }
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], User) }
      it{ should not_be_able_to(:manage, admin) }
      it{ should     be_able_to(:update, @supervisor) }
      it{ should not_be_able_to([:read, :edit, :create, :destroy], @supervisor) }
      it{ should not_be_able_to(:manage, boss) }
      it{ should not_be_able_to(:manage, accountant) }
      it{ should not_be_able_to(:manage, supervisor) }
      it{ should not_be_able_to(:manage, manager) }
      it{ should not_be_able_to(:manage, another_office_accountant) }
      it{ should not_be_able_to(:manage, another_office_supervisor) }
      it{ should not_be_able_to(:manage, another_office_manager) }
      it{ should not_be_able_to(:manage, another_admin) }
      it{ should not_be_able_to(:manage, another_boss) }
      it{ should not_be_able_to(:manage, another_accountant) }
      it{ should not_be_able_to(:manage, another_supervisor) }
      it{ should not_be_able_to(:manage, another_manager) }
      it{ should     be_able_to(:offline_version, User) }
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], User) }
      it{ should not_be_able_to(:manage, admin) }
      it{ should     be_able_to(:update, @manager) }
      it{ should not_be_able_to([:read, :edit, :create, :destroy], @manager) }
      it{ should not_be_able_to(:manage, boss) }
      it{ should not_be_able_to(:manage, accountant) }
      it{ should not_be_able_to(:manage, supervisor) }
      it{ should not_be_able_to(:manage, manager) }
      it{ should not_be_able_to(:manage, another_office_accountant) }
      it{ should not_be_able_to(:manage, another_office_supervisor) }
      it{ should not_be_able_to(:manage, another_office_manager) }
      it{ should not_be_able_to(:manage, another_admin) }
      it{ should not_be_able_to(:manage, another_boss) }
      it{ should not_be_able_to(:manage, another_accountant) }
      it{ should not_be_able_to(:manage, another_supervisor) }
      it{ should not_be_able_to(:manage, another_manager) }
      it{ should     be_able_to(:offline_version, User) }
    end
  end

  describe "widgets" do
    let(:resource) { FactoryGirl.create(:widget, :company => company) }
    let(:unresource) { FactoryGirl.create(:widget, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Boss::Widget) }
      it{ should     be_able_to(:create, Boss::Widget) }
      it{ should     be_able_to(:new, Boss::Widget) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Boss::Widget) }
      it{ should     be_able_to(:create, Boss::Widget) }
      it{ should     be_able_to(:new, Boss::Widget) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index], Boss::Widget) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index], Boss::Widget) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index], Boss::Widget) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource) }
    end
  end

  describe "claims" do
    let(:resource) { FactoryGirl.create(:claim, :company => company) }
    let(:unresource) { FactoryGirl.create(:claim, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, Claim) }
      it{ should     be_able_to(:scroll, Claim) }
      it{ should     be_able_to(:totals, Claim) }
      it{ should     be_able_to(:printer, Claim) }
      it{ should     be_able_to(:new, Claim) }
      it{ should     be_able_to(:create, Claim) }
      it{ should     be_able_to(:update_bonus, Claim) }
      it{ should     be_able_to(:lock, Claim) }
      it{ should     be_able_to(:unlock, Claim) }
      it{ should     be_able_to(:read, :robokassa_pay) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, Claim) }
      it{ should     be_able_to(:scroll, Claim) }
      it{ should     be_able_to(:totals, Claim) }
      it{ should     be_able_to(:printer, Claim) }
      it{ should     be_able_to(:new, Claim) }
      it{ should     be_able_to(:create, Claim) }
      it{ should     be_able_to(:update_bonus, Claim) }
      it{ should     be_able_to(:lock, Claim) }
      it{ should     be_able_to(:unlock, Claim) }
      it{ should     be_able_to(:read, :robokassa_pay) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should     be_able_to(:index, Claim) }
      it{ should     be_able_to(:scroll, Claim) }
      it{ should     be_able_to(:totals, Claim) }
      it{ should     be_able_to(:printer, Claim) }
      it{ should     be_able_to(:new, Claim) }
      it{ should     be_able_to(:create, Claim) }
      it{ should     be_able_to(:update_bonus, Claim) }
      it{ should     be_able_to(:lock, Claim) }
      it{ should     be_able_to(:unlock, Claim) }
      it{ should     be_able_to(:manage, resource)}
      it{ should not_be_able_to([:read], :robokassa_pay) }
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should     be_able_to(:index, Claim) }
      it{ should     be_able_to(:scroll, Claim) }
      it{ should not_be_able_to([:totals, :update_bonus], Claim) }
      it{ should     be_able_to(:printer, Claim) }
      it{ should     be_able_to(:new, Claim) }
      it{ should     be_able_to(:create, Claim) }
      it{ should     be_able_to(:lock, Claim) }
      it{ should     be_able_to(:unlock, Claim) }
      it{ should not_be_able_to([:read], :robokassa_pay) }
      it{ should not_be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource) }
    end

    context "when user is manager" do
      let(:user){ @manager }
      let(:resource) { FactoryGirl.create(:claim, :company => company, :office => office, :user => user) }
      let(:resource2) { FactoryGirl.create(:claim, :company => company, :office => office, :assistant => user) }
      it{ should     be_able_to(:index, Claim) }
      it{ should     be_able_to(:scroll, Claim) }
      it{ should not_be_able_to([:totals, :update_bonus], Claim) }
      it{ should     be_able_to(:printer, Claim) }
      it{ should     be_able_to(:new, Claim) }
      it{ should     be_able_to(:create, Claim) }
      it{ should     be_able_to(:lock, Claim) }
      it{ should     be_able_to(:unlock, Claim) }
      it{ should not_be_able_to([:read], :robokassa_pay) }
      it{ should not_be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, resource2) }
      it{ should not_be_able_to(:manage, unresource) }
    end
  end

  describe "demo company and user" do
    def create_demo_resources
      @demo_company = Company.new(subdomain: 'demo', name: 'demo')
      @demo_company.save(validate: false)
      @demo_office = create(:office, company: @demo_company)
      @demo_user = create(:boss, company: @demo_company, office: @demo_office, login: 'demo')
    end

    clean_once do
      before(:all) { create_demo_resources }

      subject(:ability){ Ability.new(@demo_user) }

      it{ should_not be_able_to(:update, @demo_company) }
      it{ should_not be_able_to(:destroy, @demo_company) }
      it{ should_not be_able_to(:update, @demo_user) }
      it{ should_not be_able_to(:destroy, @demo_user) }
    end
  end

  describe "user payments" do
    let(:resource) { FactoryGirl.create(:user_payment, :company => company, :user => user) }
    let(:unresource) { FactoryGirl.create(:user_payment, :company => another_company) }
    context "when user is admin" do
      let(:user){ @admin }
      it{ should     be_able_to(:index, UserPayment) }
      it{ should     be_able_to(:create, UserPayment) }
      it{ should     be_able_to(:new, UserPayment) }
      it{ should     be_able_to(:manage, resource) }
      it{ should     be_able_to(:manage, unresource) }
    end

    context "when user is boss" do
      let(:user){ @boss }
      it{ should     be_able_to(:index, UserPayment) }
      it{ should     be_able_to(:create, UserPayment) }
      it{ should     be_able_to(:new, UserPayment) }
      it{ should     be_able_to(:manage, resource) }
      it{ should not_be_able_to(:manage, unresource)}
      context "and status" do
        context "was success" do
          let(:resource) { FactoryGirl.create(:success_user_payment, :company => company) }
          it{ should  not_be_able_to([:destroy], resource) }
        end
        context "was approved" do
          let(:resource) { FactoryGirl.create(:approved_user_payment, :company => company) }
          it{ should  not_be_able_to([:destroy], resource) }
        end
        context "was fail" do
          let(:resource) { FactoryGirl.create(:fail_user_payment, :company => company) }
          it{ should  not_be_able_to([:destroy], resource) }
        end
      end
    end

    context "when user is accountant" do
      let(:user){ @accountant }
      it{ should not_be_able_to([:create, :new, :index, :read], UserPayment) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is supervisor" do
      let(:user){ @supervisor }
      it{ should not_be_able_to([:create, :new, :index, :read], UserPayment) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end

    context "when user is manager" do
      let(:user){ @manager }
      it{ should not_be_able_to([:create, :new, :index, :read], UserPayment) }
      it{ should not_be_able_to(:manage, resource)}
      it{ should not_be_able_to(:manage, unresource)}
    end
  end
end
