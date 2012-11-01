# -*- encoding : utf-8 -*-
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

end
