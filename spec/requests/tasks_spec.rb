# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tasks", js: true do
  include ActionView::Helpers
  include TasksHelper
  before { login_as_admin }
  subject { page }

  describe "list of task" do
    let(:new_tasks) { create_list(:new_task, 2) }
    let(:worked_tasks) { create_list(:worked_task, 2) }
    let(:finished_tasks) { create_list(:finished_task, 2) }
    let(:canceled_tasks) { create_list(:canceled_task, 2) }
    let(:active_tasks) { new_tasks + worked_tasks }
    let(:inactive_tasks) { finished_tasks + canceled_tasks }
    let(:tasks) { active_tasks + finished_tasks + canceled_tasks }

    before do
      tasks
      visit tasks_path
    end

    it "should contain add button, filter by status and bug, links and data for each task" do
      # Add button
      should have_selector("a[href='#{new_task_path}']")

      # Filters
      within "form.filter" do
        should have_field("filter")
        within "select[name='status']" do
          status_filter_options.each do |option|
            should have_selector("option[value='#{option[1]}']", text: option[0])
          end
        end
        within "select[name='type']" do
          type_filter_options.each do |option|
            should have_selector("option[value='#{option[1]}']", text: option[0])
          end
        end
      end

      # Default list should not contain inactive tasks
      inactive_tasks.each do |task|
        should_not have_selector("#task-#{task.id}")
      end

      # Active tasks data
      active_tasks.each do |task|
        within "#task-#{task.id}" do
          should have_content(truncate task.body, length: 80)
          should have_content(truncate task.comment, length: 80)
          should have_content(task.user.login) if task.user
          should have_content(task.executer.login) if task.executer
          should have_content(I18n.t("status.#{task.status}"))
          should have_content(I18n.l(task.start_date, format: :long)) if task.start_date
          should have_content(I18n.l(task.end_date, format: :long)) if task.end_date
          should have_field("bug_#{task.id}")

          should have_link(I18n.t('status.actions.accept'))
          should have_link(I18n.t('status.actions.finish'))
          should have_link(I18n.t('status.actions.canсel'))

          should have_selector("a[href='#{edit_task_path(task)}']")
        end
      end
    end
  end

  describe "submit form" do

    before do
      visit '/tasks/new'
    end

    describe "create task" do
      let(:task_attrs) { attributes_for(:task) }

      context "when invalid attribute values" do

        it "should not create an task, should show error message" do
          expect {
            fill_in "task[body]", with: ""
            click_link I18n.t('save')
          }.to_not change(Task, :count)
          current_path.should eq(tasks_path)
          page.should have_selector("div.error_messages")
        end
      end

      context "when invalid attribute values" do

        it "should create an task, redirect to task_path" do
          expect {
            fill_in "task[body]", with: "TEST"
            click_link I18n.t('save')
          }.to change(Task, :count).by(1)
          current_path.should eq(tasks_path)
        end
      end
    end
  end

  describe "update" do
    let(:task) { create_list(:new_task, 1)[0]  }

    before do
      task
      visit tasks_path
    end

    it 'edit status task' do
      click_link "task_#{task.id}"  

      visit edit_task_path(task.id)
      
      current_path.should eq("/tasks/#{task.id}/edit")
    
      expect {
        fill_in "task[status]", with: "new"
        click_link I18n.t('save')
      }

      task.status.should eq('new')
    end

    # it 'task click_link accept' do

    #   within "#task-#{task.id}" do

    #     click_link "accept_task_#{task.id}"  

    #     should has_content()

    #   end
      
    # end
  end
end
