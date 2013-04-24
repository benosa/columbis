# -*- encoding : utf-8 -*-
require 'spec_helper'

describe TasksController do
  before (:each) do
    @task = FactoryGirl.create(:task)
    @admin = @task.user
    test_sign_in(@admin)
  end

  describe 'GET index' do
    before { get :index }

    it 'should be successful' do
      response.should be_success
    end

    it 'should find all tasks' do
      assigns[:tasks].size.should > 0
    end

    it 'should render tasks/index.html' do
      response.should render_template('index')
    end
  end

  describe 'GET new' do
    def do_get
      get :new
    end

    before (:each) do
      do_get
    end

    it 'should render tasks/new' do
      response.should render_template('new')
    end

    it 'should be successful' do
      response.should be_success
    end
  end

  describe 'POST create' do
    def do_task
      post :create, task: { body: 'Test create task', status: 'new' }
    end

    it 'should redirect to tasks' do
      do_task
      response.should redirect_to tasks_path
    end

    it 'should change task count up by 1' do
      lambda { do_task }.should change{ Task.count }.by(1)
    end
  end

  describe 'PUT update status finish' do
    %w/finish cancel/.each do |status|
      it "should change to #{status}" do
        put :update, id: @task.id, task: { status: status, body: 'TEST', comment: "test #{status}" }
        assigns[:task].body.should == 'TEST'
        assigns[:task].comment.should == "test #{status}"
        assigns[:task].status.should == status
        response.should redirect_to tasks_path
      end
    end
    it "should change to work" do
        put :update, id: @task.id, task: { status: 'work' }
        assigns[:task].status.should == 'work'
        assigns[:task].executer_id.should == @admin.id
        response.should redirect_to tasks_path
      end
  end
end
