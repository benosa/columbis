require 'test_helper'

class ClaimsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Claim.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Claim.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Claim.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to claim_url(assigns(:claim))
  end

  def test_edit
    get :edit, :id => Claim.first
    assert_template 'edit'
  end

  def test_update_invalid
    Claim.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Claim.first
    assert_template 'edit'
  end

  def test_update_valid
    Claim.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Claim.first
    assert_redirected_to claim_url(assigns(:claim))
  end

  def test_destroy
    claim = Claim.first
    delete :destroy, :id => claim
    assert_redirected_to claims_url
    assert !Claim.exists?(claim.id)
  end
end
