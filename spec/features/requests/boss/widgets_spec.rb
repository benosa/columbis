# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Widgets:" do
  include ActionView::Helpers

  before(:all) do
    @boss = create_user_with_company_and_office(:boss)
    @company = @boss.company
  end

  before(:each) do
    login_as @boss
    visit boss_index_path
  end

  subject { page }

  it 'widgets on base length and on page length should be equal' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id)
    all('.widget').length.should == widgets.length
  end

  it 'should stands on its position' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id)
      .order("position ASC").map{|widget| widget.id}
    all('.widget').map{|widget| widget['position'].to_i}.should == widgets
  end

  it 'should stands on its position after editing position on database' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id)
      .order("position ASC")
    i = widgets.length
    widgets.each do |widget|
      widget.position = i
      widget.save
      i -= 1
    end
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id)
      .order("position ASC").map{|widget| widget.id}
    visit boss_index_path

    all('.widget').map{|widget| widget['position'].to_i}.should == widgets
  end

  it 'should have buttons for editing widgets position and settings' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id)
    widgets.each do |widget|
      page.should have_selector("div.widget[position='#{widget.id}'] div.widget-menu div.widget-btn-more")
      page.should have_selector("div.widget[position='#{widget.id}'] div.widget-menu a.settings\#settings_#{widget.id}")
    end
  end

  it 'chart widgets should have period and size settings' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id).where(:widget_type => "chart")
    widgets.each do |widget|
      page.should have_selector("form.edit_boss_widget[id='edit_boss_widget_#{widget.id}'] select\#boss_widget_period[name='boss_widget[period]']")
      page.should have_selector("form.edit_boss_widget[id='edit_boss_widget_#{widget.id}'] select\#boss_widget_view[name='boss_widget[view]']")
    end
  end

  it 'leader widgets should have period settings' do
    widgets = Boss::Widget.where(:company_id => @company.id).where(:user_id => @boss.id).where(:widget_type => "leader")
    widgets.each do |widget|
      page.should have_selector("form.edit_boss_widget[id='edit_boss_widget_#{widget.id}'] select\#boss_widget_period[name='boss_widget[period]']")
    end
  end
end