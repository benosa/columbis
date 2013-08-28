# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Widgets:" do
  include ActionView::Helpers

  before(:all) do
    @boss = create_user_with_company_and_office(:boss)
    @company = @boss.company
    login_as @boss
  end

  before do
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
end