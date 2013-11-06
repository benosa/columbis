module VisitorsHelper
  def visitors_confirm_url
    url_for :controller => 'visitors', :action => 'confirm'
  end

end
