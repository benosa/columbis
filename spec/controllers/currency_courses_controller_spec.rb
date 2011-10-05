require File.dirname(__FILE__) + '/../spec_helper'

describe CurrencyCoursesController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => CurrencyCourse.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    CurrencyCourse.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    CurrencyCourse.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(currency_course_url(assigns[:currency_course]))
  end

  it "edit action should render edit template" do
    get :edit, :id => CurrencyCourse.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    CurrencyCourse.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CurrencyCourse.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    CurrencyCourse.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CurrencyCourse.first
    response.should redirect_to(currency_course_url(assigns[:currency_course]))
  end

  it "destroy action should destroy model and redirect to index action" do
    currency_course = CurrencyCourse.first
    delete :destroy, :id => currency_course
    response.should redirect_to(currency_courses_url)
    CurrencyCourse.exists?(currency_course.id).should be_false
  end
end
