# -*- encoding : utf-8 -*-
# require 'spec_helper'

# describe UploadsController do
#   before(:all) do
#     @admin = FactoryGirl.create(:admin)
#     @printer = FactoryGirl.create(:act, :company => @admin.company)
#     @def_params = {
#       :model => 'printer',
#       :id => @printer.id,
#       :filename => @printer.template.model[:template]
#     }
#   end

#   before(:each) do
#     test_sign_in(@admin)
#     @controller.stub!(:send_file).and_return(@controller.render :nothing => true)
#   end

#   let(:params) { @def_params }

#   it 'should send file with inline' do
#     @controller.should_receive(:send_file).and_return(@controller.render :nothing => true)
#     get :get_file, params
#   end

#   context 'to download file' do
#     let(:params) { @def_params.merge!(:download => true) }
#     it 'should send file to download' do
#       @controller.should_receive(:send_file).and_return(@controller.render :nothing => true)
#       get :get_file, params
#     end
#   end

#   context "invalid params" do
#     let(:params) { @def_params.merge!(:model => 'blalabla') }
#     it 'should render nothing if params invalid' do
#       @controller.should_not_receive(:send_file).and_return(@controller.render :nothing => true)
#       get :get_file, params
#     end
#   end
# end