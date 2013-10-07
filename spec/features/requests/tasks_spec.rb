# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tasks:", js: true do
  include ActionView::Helpers
  include TasksHelper

  before(:all) do
    @admin = create_user_with_company_and_office(:admin)
    @boss = FactoryGirl.create(:boss, :company => @admin.company, :office => @admin.office)
  end

  clean_once_with_sphinx do # database cleaning will excute only once after this block
    let(:user) { @admin }
    before do
      login_as user
    end

    subject { page }

    describe "task list" do
      let(:new_tasks) { create_list(:new_task, 2) }
      let(:worked_tasks) { create_list(:worked_task, 2, executer: @admin) }
      let(:finished_tasks) { create_list(:finished_task, 2, executer: @admin) }
      let(:canceled_tasks) { create_list(:canceled_task, 2, executer: @admin) }
      let(:active_tasks) { new_tasks + worked_tasks }
      let(:inactive_tasks) { finished_tasks + canceled_tasks }
      let(:offered_tasks) { create_list(:worked_task, 2, :not_bug, executer: @admin) }
      let(:tasks) { active_tasks + finished_tasks + canceled_tasks + offered_tasks }

      before(:all) do
        tasks
      end

      before do
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
            should have_content(task.user.full_name) if task.user
            should have_content(task.user.company.name) if task.user && task.user.role != 'admin'
            should have_content(task.user.email) if task.user
            should have_content(task.executer.login) if task.executer
            should have_content(task.executer.full_name) if task.executer
            should have_content(I18n.t("status.#{task.status}"))
            should have_content(I18n.l(task.created_at, format: :long)) if task.created_at
            should have_content(I18n.l(task.start_date, format: :long)) if task.start_date
            should have_content(I18n.l(task.end_date, format: :long)) if task.end_date
            has_field?("bug_#{task.id}").should be_true

            should have_link(I18n.t('status.actions.accept'))
            should have_link(I18n.t('status.actions.finish'))
            should have_link(I18n.t('status.actions.canсel'))
            should have_selector("a[href='#{edit_task_path(task)}']")
            should have_selector("a[href='/tasks/#{task.id}/image']")
          end
        end
      end

      describe "when filter by status" do
        # before do
        #   page.find('select[name=status]').find(:xpath, '..').click # find(:xpath, '..') - is parent element
        # end

        it "should contain all tasks" do
          page.select t('task_type.all'), :from => 'type_filter_options'
          page.select t('task_status.all'), :from => 'status_filter_options'
          tasks.each do |task|
            should have_selector("#task-#{task.id}")
          end
        end

        it "should contain only active tasks" do
          page.select t('task_type.all'), :from => 'type_filter_options'
          active_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          inactive_tasks.each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only new tasks" do
          page.select t('task_status.new'), :from => 'status_filter_options'
          new_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (worked_tasks + finished_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only worked tasks" do
          page.select t('task_status.work'), :from => 'status_filter_options'
          worked_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (new_tasks + finished_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only finished tasks" do
          page.select t('task_status.finish'), :from => 'status_filter_options'
          finished_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (canceled_tasks + worked_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only canceled tasks" do
          page.select t('task_status.cancel'), :from => 'status_filter_options'
          canceled_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (finished_tasks + worked_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end
      end

      describe "when filter by bug" do
        before do
          page.find('select[name=type]').find(:xpath, '..').click # find(:xpath, '..') - is parent element
        end

        it "should contain bug and not bug tasks" do
          page.select t('task_type.bug'), :from => 'type_filter_options'
          page.select t('task_status.all'), :from => 'status_filter_options'
          (active_tasks + offered_tasks).each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only bug tasks" do
          page.select t('task_type.bug'), :from => 'type_filter_options'
          active_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          offered_tasks.each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only not bug tasks" do
          page.select t('task_type.offer'), :from => 'type_filter_options'
          active_tasks.each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
          offered_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
        end
      end

      describe "when filter by search filter" do

        it "should contain only tasks with the search word" do
          @filter = active_tasks.first.body.split(/[\s,.']/).first # get first word from first task
          fill_in('filter', with: @filter) # trigger search by word
          active_tasks.each do |task|
            if task.body.index(@filter) or task.comment.try(:index, @filter)
              page.has_selector?("#task-#{task.id}").should be_true
            else
              page.has_no_selector?("#task-#{task.id}").should be_true
            end
          end
        end

        context "when user boss" do
          let(:user) { @boss }
          let(:new_tasks) { create_list(:new_task, 2, :user => user, :executer => @admin) }

          it "should contain only tasks with the search word" do
            filter = new_tasks.first.body.split(/[\s,.']/).first # get first word from first task
            fill_in('filter', with: filter) # trigger search by word
            new_tasks.each do |task|
              if task.body.index(filter) or task.comment.try(:index, filter)
                page.has_selector?("#task-#{task.id}").should be_true
              else
                page.has_no_selector?("#task-#{task.id}").should be_true
              end
            end
          end

          it "should not contain task with the search word in invisible columns" do
            filter = @admin.login
            fill_in('filter', with: filter)
            new_tasks.each do |task|
              page.has_no_selector?("#task-#{task.id}").should be_true
            end
            filter = user.email
            fill_in('filter', with: filter)
            new_tasks.each do |task|
              page.has_no_selector?("#task-#{task.id}").should be_true
            end
            filter = user.login
            fill_in('filter', with: filter)
            new_tasks.each do |task|
              page.has_no_selector?("#task-#{task.id}").should be_true
            end
          end
        end
      end

      describe "when change task status by links" do

        it 'accept task' do
          task = new_tasks[0]
          expect {
            click_link "accept_task_#{task.id}"
            sleep(2)
            task.reload
          }.to change(task, :status).to('work')
        end

        it 'finish task' do
          task = worked_tasks[0]
          expect {
            click_link "finish_task_#{task.id}"
            find(".popover .comment_form").fill_in 'task[comment]', with: 'qweqwe'
            find(".popover .comment_form").click_link('task_save')
            sleep(2)
            task.reload
          }.to change(task, :status).to('finish')
          sleep(1) # need becouse fadeOut
          find("#task-#{task.id}").visible?.should be_false
        end

        it 'cancel task' do
          task = worked_tasks[1]
          expect {
            click_link "cancel_task_#{task.id}"
            find(".popover .comment_form").click_link('task_save')
            sleep(2)
            task.reload
          }.to change(task, :status).to('cancel')
          sleep(1) # need becouse fadeOut
          find("#task-#{task.id}").visible?.should be_false
        end
      end
    end

    describe "submit task form" do

      before do
        visit new_task_path
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

        context "when valid attribute values" do

          it "should create an task, redirect to task_path" do
            expect {
              fill_in "task[body]", with: "TEST"
              click_link I18n.t('save')
            }.to change(Task, :count).by(1)
            current_path.should eq(tasks_path)
          end

          it "should create an task, when bad image, without image" do
            expect {
              fill_in "task[body]", with: "TEST"
              attach_file "task[image]", Rails.root.join('spec', 'factories', 'files', "big_file.mov")
              click_link I18n.t('save')
            }.to change(Task, :count).by(1)
            Task.where(:body => "TEST").last.image?.should be_false
          end

          it "should show message when image is incorrect" do
            attach_file "task[image]", Rails.root.join('spec', 'factories', 'files', "big_file.mov")
            page.should have_content("Слишком большой размер.")
            page.should have_content("Не верный формат файла.")
          end
        end
      end
    end

    describe "update task" do

      let(:task) { create(:new_task) }

      before do
        task
        visit tasks_path
      end

      it 'should not create an task, should show error message' do
        click_link "edit_task_#{task.id}"
        current_path.should eq("/tasks/#{task.id}/edit")

        expect {
          fill_in "task_body", with: ""
          fill_in "task_comment", with: "qweqwe"
          click_link I18n.t('save')
        }.to_not change(task, :body).from(task.body).to('')
        current_path.should eq("/tasks/#{task.id}")
        page.should have_selector("div.error_messages")
      end

      it 'should edit an task, redirect to task_path' do
        click_link "edit_task_#{task.id}"
        current_path.should eq("/tasks/#{task.id}/edit")

        expect {
          fill_in "task_body", with: "qweqwe"
          fill_in "task_comment", with: "qweqwe"
          #page.select t("status.work"), from: "task_status"
          click_link I18n.t('save')
          task.reload
        }.to change(task, :body).from(task.body).to('qweqwe')
        task.comment.should eq("qweqwe")
        current_path.should eq(tasks_path)
      end
    end

  end
end
