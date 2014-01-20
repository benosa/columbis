# -*- encoding : utf-8 -*-
require 'import'

module CompaniesHelper

  def sort_printers(printers)
    printers.sort do |a, b|
      if a.mode.nil? || b.mode.nil?
        a.mode.nil? ? 1 : -1
      elsif a.mode == 'memo' && b.mode == 'memo'
        a.country_id <=> b.country_id
      else
        a.mode == 'memo' ? 1 : (b.mode == 'memo' ? -1 : a.mode <=> b.mode)
      end
    end
  end

  def import(tables, file_path, company_id, import_new)
    importing = Import::Formats::XLS.new(tables, file_path, company_id, import_new)
    importing.start
  end

end
