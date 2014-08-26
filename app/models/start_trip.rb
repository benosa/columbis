class StartTrip < ActiveRecord::Base
 # include ActiveSupport::Configurable
 # include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  attr_accessible :step, :user_id

  belongs_to :user

  def check_step_actions_path(req)
    path = false
    path = dashboard_users_path if (step == 2 || step == 4) && req[:path] != dashboard_users_path
    if (step == 3 || step == 5) && req[:path] != new_dashboard_user_path && req[:get]
      path = new_dashboard_user_path
    end

    path
  end

  def check_step_actions_cookie(step, company, user)
    if step == 1
      if company && company.errors.count == 0
        self.step = 2
        self.save
      end
    end

    if step == 2 || step == 4
      self.step = step + 1
      self.save
    end

    if step == 3 || step == 5
      if user && user.errors.count == 0
        self.step = step + 1
        self.save
      end
    end
  end
end
