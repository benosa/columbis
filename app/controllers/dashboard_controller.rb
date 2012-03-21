class DashboardController < ApplicationController
  def index
    authorize! :dasboard_index, current_user
  end
end
