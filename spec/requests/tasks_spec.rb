# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tasks:", js: true do
  include ActionView::Helpers
  include TasksHelper

  clean_once_with_sphinx do

    before { login_as_admin }
    subject { page }

    describe "list of task" do
      let(:new_tasks) { create_list(:new_task, 2) }
      let(:worked_tasks) { create_list(:worked_task, 2) }
      let(:finished_tasks) { create_list(:finished_task, 2) }
      let(:canceled_tasks) { create_list(:canceled_task, 2) }
      let(:active_tasks) { new_tasks + worked_tasks }
      let(:inactive_tasks) { finished_tasks + canceled_tasks }
      let(:offered_tasks) { create_list(:worked_task, 2, :not_bug) }
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
        page.driver.render(Rails.root.join('tmp/page.png'), full: true)
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

      describe "when filter by status" do
        before do
          page.find('select[name=status]').find(:xpath, '..').click # find(:xpath, '..') - is parent element
        end

        it "should contain all tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.all')).click
          wait_for_filter_refresh # wait until ajax request has done
          tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          # page.driver.render(Rails.root.join('tmp/page1.png'), full: true)
        end

        it "should contain only active tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.active')).click
          wait_for_filter_refresh
          active_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          inactive_tasks.each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only new tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.new')).click
          wait_for_filter_refresh
          new_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (worked_tasks + finished_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only worked tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.work')).click
          wait_for_filter_refresh
          worked_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (new_tasks + finished_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only finished tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.finish')).click
          wait_for_filter_refresh
          finished_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          (canceled_tasks + worked_tasks).each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only canceled tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_status.cancel')).click
          wait_for_filter_refresh
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
          find('.ik_select_block').find('li', text: I18n.t('task_type.all')).click
          wait_for_filter_refresh
          (active_tasks + offered_tasks).each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only bug tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_type.bug')).click
          wait_for_filter_refresh
          active_tasks.each do |task|
            has_selector?("#task-#{task.id}").should be_true
          end
          offered_tasks.each do |task|
            has_no_selector?("#task-#{task.id}").should be_true
          end
        end

        it "should contain only not bug tasks" do
          find('.ik_select_block').find('li', text: I18n.t('task_type.offer')).click
          wait_for_filter_refresh
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
          @filter = active_tasks.first.body.split.first # get first word from first task
          fill_in('filter', with: @filter) # trigger search by word
          wait_for_filter_refresh
          active_tasks.each do |task|
            if task.body.index(@filter) or task.comment.try(:index, @filter)
              has_selector?("#task-#{task.id}").should be_true
            else
              has_no_selector?("#task-#{task.id}").should be_true
            end
          end
        end
      end
    end

  end

end
