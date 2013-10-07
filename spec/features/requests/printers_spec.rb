# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Printers:", js: true do
  subject { page }

  before(:all) do
    @admin = FactoryGirl.create(:admin)
    @act = FactoryGirl.create(:act, :company => @admin.company)
    @warranty = FactoryGirl.create(:warranty, :company => @admin.company)
    @permit = FactoryGirl.create(:permit, :company => @admin.company)
    @memo = FactoryGirl.create(:memo, :company => @admin.company)
    @contract = FactoryGirl.create(:contract, :company => @admin.company)
    @printers = [@act, @warranty, @permit, @memo, @contract]
  end

  before(:each) do
    login_as @admin
  end

  describe "create printer" do
    it "should valid" do
      visit new_printer_path
      expect {
        page.click_link I18n.t('save')
      }.to change(Printer, :count).by(1)
    end
  end

  describe "update printer" do
    it 'should edit a printer, redirect to printers_path' do
      @printer = @printers.first
      visit printers_path
      page.find("tr[id='printer_#{@printer.id}'] a.edit_row").click
      current_path.should eq edit_printer_path(@printer.id)
      expect {
        page.find("p[id='mode_name'] div.ik_select_link").click
        page.find("div.ik_select_list_inner ul li span[title='permit']").click
        click_link I18n.t('save')
        @printer.reload
      }.to change(@printer, :mode).from(@printer.mode).to("permit")
    end
  end

  describe "delete printer" do
  end

  describe "printers list" do
    clean_once_with_sphinx do

      before(:each) do
        @printers = Printer.all
      end

      def take_elements
        elements = []

        (2..(@printers.length+1)).to_a.each do |i|
          elements << page.find(:xpath, "//table/tbody/tr[#{i}]/td[1]/p").text.first
        end
        elements
      end #this method return string array from first column

      def sort_printers_asc_by (column)
        @printers
          .sort{|x,y| x.try(column) <=> y.try(column) }
          .map{|u| I18n.t("activerecord.attributes.printer.#{u.try(column)}").first }
      end

      def sort_printers_desc_by (column)
        @printers
          .sort{|x,y| y.try(column) <=> x.try(column) }
          .map{|u| I18n.t("activerecord.attributes.printer.#{u.try(column)}").first }
      end

      it "should sort by column name" do
        visit printers_path
        # It's checking by first characters, becouse sorts in the test
        # and sort on the page may a little different
        page.should have_selector("a.sort_active.asc[data-sort='mode']")
        take_elements.should == sort_printers_asc_by(:mode)
        page.find("a[data-sort='mode']").click
        page.should have_selector("a.sort_active.desc[data-sort='mode']")
        take_elements.should == sort_printers_desc_by(:mode)
      end

      it "should filter sotring" do
        visit printers_path
        filter = @printers.first.try(:mode).split(/[\s,.']/).first
        fill_in('filter', with: filter)
        @printers.each do |printer|
          if printer.try(:mode).index(filter)
            page.has_content?(printer.try(:mode)).should be_true
          else
            page.has_no_content?(printer.try(:mode)).should be_true
          end
        end
      end
    end
  end
end