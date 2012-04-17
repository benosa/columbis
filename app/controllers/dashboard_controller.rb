class DashboardController < ApplicationController
  def index
    authorize! :dasboard_index, current_user
  end

  def sign_in_as
    authorize! :dasboard_sign_in_as, current_user
    self.remember_admin_id = current_user.id
    sign_in :user, User.find(params[:user_id])

    redirect_to root_path
  end

  # doesn't work: need store admin between request
#  def sign_out_as
#    if self.remember_admin_id?
#      sign_in :user, User.find(self.remember_admin_id)
#      clear_remembered_admin_id
#    end

#    redirect_to root_path
#  end
end
