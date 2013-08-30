# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ClaimsController do
  def create_prerequisites
    @office = FactoryGirl.create(:office)
    @country = FactoryGirl.create(:country)
    @resort = FactoryGirl.create(:resort)
    @city = FactoryGirl.create(:city)

    @company = FactoryGirl.create(:company)
    @applicant = FactoryGirl.create(:applicant, company_id: @company.id, address: FactoryGirl.create(:address))
    @operator = FactoryGirl.create(:operator)
    stub_current_company(@company)
    stub_current_office(@office)
  end

  def create_users
    @admin = FactoryGirl.create(:admin)
    @manager = FactoryGirl.create(:manager, office_id: @office.id, company_id: @company.id)
    stub_current_user(@admin)
    test_sign_in(@admin)
  end

  def create_claim
    @claim = FactoryGirl.create(:claim, user_id: @manager.id, office_id: @office.id,
                  country_id: @country.id, resort_id: @resort.id, :city_id => @city.id, company: @company)
  end

  before(:each) do
    create_prerequisites
    create_users
    create_claim
  end

  describe 'GET index' do
    before{ get :index }

    it { response.should be_success}
    it { should assign_to(:claims) }

    it {response.should render_template('index') }
  end

  describe 'GET new' do
    before { get :new }
    it { response.should render_template('new') }
    it { response.should be_success }
  end

  describe 'POST create' do
    def do_claim(extra_params = {})
      params = {
        claim: { user_id: @manager.id, check_date: Time.zone.now, reservation_date: Time.zone.now + 14,
        office_id: @office.id, applicant_attributes: @applicant.attributes.merge(address:  @applicant.address.joint_address),
        operator_id: @operator.id, arrival_date: Time.zone.now + 14, operator_price_currency: "rur", tour_price_currency: "rur",
        flights_attributes: [attributes_for(:flight), attributes_for(:flight)], tourist_stat: 'some category' }
      }
      params.merge!(extra_params) unless extra_params.empty?
      post :create, params
    end

    it 'should redirect to claim list' do
      do_claim(commit: I18n.t('save_and_close'))
      response.should redirect_to claims_path
    end

    it 'should redirect to claim form' do
      do_claim
      response.should redirect_to edit_claim_path(Claim.last.id)
    end

    it 'should change claim count up by 1' do
      expect { do_claim }.to change{ Claim.count }.by(1)
    end

    it 'should change flight count up by 2' do
      expect { do_claim }.to change{ Flight.count }.by(2)
    end
  end

  describe 'GET edit' do
    before { get :edit, :id => @claim.id }
    it{ response.should render_template('edit') }
    it{ response.should be_success }
    it{ assigns[:claim].id.should == @claim.id }
  end

  # describe 'PUT update' do
  #   reservation_date = Time.zone.now + 20
  #   before{ put :update, id: @claim.id, claim: { user_id: @manager.id, check_date: Time.zone.now, reservation_date: reservation_date,
  #     office_id: @office.id, applicant: @applicant.attributes, operator_id: @operator.id, arrival_date: reservation_date, operator_price_currency: "rur", tour_price_currency: "rur" } }
  #   # it 'should change claim name' do
  #   #   assigns[:claim].reservation_date.should == reservation_date
  #   # end

  #   it 'should redirect to claims/show.html' do
  #     response.should redirect_to(claims_url)
  #   end
  # end

  describe 'DELETE destroy' do
    def do_delete
      delete :destroy, :id => @claim.id
    end

    it{ response.should be_success }

    it 'should redirect to claims/index.html' do
      do_delete
      response.should redirect_to(claims_url)
    end

    it 'should change claim count down by 1' do
      expect { do_delete }.to change{ Claim.count }.by(-1)
    end
  end

  describe 'lock_unlock' do
    context "success lock" do
      before do
        get :lock, :id => @claim.id
      end
      it{ response.body.should == { :message  => I18n.t('claims.messages.locked') }.to_json }
    end

    context "success unlock" do
      before do
        @claim.lock(@admin.id)
        @claim.save
        get :unlock, :id => @claim.id
      end
      it{ response.body.should == { :unlocked => 1 }.to_json }
    end

    context "unsuccess lock" do
      before do
        @claim.lock(@manager.id)
        @claim.save
        get :lock, :id => @claim.id
      end
      it{ response.body.should == { :locked => @manager.id }.to_json }
    end

    context "unsuccess unlock" do
      before do
        get :unlock, :id => @claim.id
      end
      it{ response.body.should == { :wrong_user => 1 }.to_json }
    end
  end

  # describe 'GET show' do
  #   before{ get :show, :id => @claim.id }

  #   it{ response.should be_success }

  #   it{ assigns[:claim].id.should == @claim.id }

  #   it { response.should render_template('show') }
  # end
end
