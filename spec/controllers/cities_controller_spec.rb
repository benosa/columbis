# -*- encoding : utf-8 -*-
# require 'spec_helper'

# describe CitiesController do
#   def create_city
#     @city = Factory(:city)
#   end

#   before (:each) do
#     create_city
#   end

#   describe 'GET index' do
#     def do_get
#       get :index
#     end

#     it 'should be successful' do
#       do_get
#       response.should be_success
#     end

#     it 'should find all cities' do
#       do_get
#       assigns[:cities].size.should > 0
#     end

#     it 'should render cities/index.html' do
#       do_get
#       response.should render_template('index')
#     end
#   end

#   describe 'GET new' do
#     def do_get
#       get :new
#     end

#     before (:each) do
#       do_get
#     end

#     it 'should render cities/new' do
#       response.should render_template('new')
#     end

#     it 'should be successful' do
#       response.should be_success
#     end
#   end

#   describe 'POST create' do
#     def do_city
#       post :create, :city => {:name => 'city'}
#     end

#     it 'should redirect to cities/show.html' do
#       do_city
#       response.should redirect_to(cities_path)
#     end

#     it 'should change city count up by 1' do
#       lambda { do_city }.should change{ City.count }.by(1)
#     end
#   end

#   describe 'GET edit' do
#     def do_get
#       get :edit, :id => @city.id
#     end

#     before (:each) do
#       do_get
#     end

#     it 'should render cities/edit' do
#       response.should render_template('edit')
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should find right city' do
#       assigns[:city].id.should == @city.id
#     end
#   end

#   describe 'PUT update' do
#     def do_put
#       put :update, :id => @city.id, :city => {:name => 'first'}
#     end

#     before(:each) do
#       do_put
#     end

#     it 'should change city name' do
#       assigns[:city].name.should == 'first'
#     end

#     it 'should redirect to cities/show.html' do
#       response.should redirect_to cities_path
#     end
#   end

#   describe 'DELETE destroy' do
#     def do_delete
#       delete :destroy, :id => @city.id
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should redirect to cities/index.html' do
#       do_delete
#       response.should redirect_to(cities_path)
#     end

#     it 'should change city count down by 1' do
#       lambda { do_delete }.should change{ City.count }.by(-1)
#     end
#   end

#   describe 'GET show' do
#     def do_get
#       get :show, :id => @city.id
#     end

#     before (:each) do
#       do_get
#     end

#     it 'should be successful' do
#       response.should be_success
#     end

#     it 'should find right city' do
#       assigns[:city].id.should == @city.id
#     end

#     it 'should render cities/show.html' do
#       response.should render_template('show')
#     end
#   end
# end
