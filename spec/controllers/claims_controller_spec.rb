# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ClaimsController do
  def create_prerequisites
    @office = FactoryGirl.create(:office)
    @country = FactoryGirl.create(:country, :name => 'Turkey')
    @resort = FactoryGirl.create(:resort)
    @city = FactoryGirl.create(:city)

    @applicant = FactoryGirl.create(:applicant)
  end

  def create_users
    @admin = FactoryGirl.create(:admin)
    @manager = FactoryGirl.create(:manager, :office_id => @office.id)
    stub_current_user(@admin)
    test_sign_in(@admin)

  end

  def create_claim
    @claim = FactoryGirl.create(:claim, :user_id => @manager.id, :office_id => @office.id,
                  :country_id => @country.id, :resort_id => @resort.id, :city_id => @city.id)
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
    def do_claim
      post :create, claim: { user:  @manager.id, check_date: Time.now, reservation_date: Time.now + 14, office_id: @office.id }
    end

    it 'should redirect to claim edit' do
      do_claim
      response.should redirect_to(edit_claim_path(Claim.last.id))
    end

    # it 'should change claim count up by 1' do
    #   expect { do_claim }.to change{ Claim.count }.by(1)
    # end
  end

#   describe 'GET edit' do
#     def do_get
#       get :edit, :id => @claim.id
#     end

#     before (:each) do
#       do_get
#     end

#     it 'should render claims/edit' do
#       response.should render_template('edit')
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should find right claim' do
#       assigns[:claim].id.should == @claim.id
#     end
#   end

# #  describe 'PUT update' do
#   pending 'PUT update' do
#     def do_put
#       put :update, :id => @claim.id, :claim => {:name => 'first'}
#     end

#     before(:each) do
#       do_put
#     end

#     it 'should change claim name' do
#       assigns[:claim].name.should == 'first'
#     end

#     it 'should redirect to claims/show.html' do
#       response.should redirect_to claims_path
#     end
#   end

# #  describe 'DELETE destroy' do
#   pending 'DELETE destroy' do
#     def do_delete
#       delete :destroy, :id => @claim.id
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should redirect to claims/index.html' do
#       do_delete
#       response.should redirect_to(claims_path)
#     end

#     it 'should change claim count down by 1' do
#       lambda { do_delete }.should change{ Claim.count }.by(-1)
#     end
#   end

# #  describe 'GET show' do
#   pending 'GET show' do
#     def do_get
#       get :show, :id => @claim.id
#     end

#     before (:each) do
#       do_get
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should find right claim' do
#       assigns[:claim].id.should == @claim.id
#     end

#     it 'should render claims/show.html' do
#       response.should render_template('show')
#     end
#   end
end
