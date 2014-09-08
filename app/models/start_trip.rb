class StartTrip < ActiveRecord::Base
 # include ActiveSupport::Configurable
 # include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  attr_accessible :step, :user_id

  belongs_to :user

  def check_step_actions_path(req, params = [])
    path = false
    path = dashboard_users_path if (step == 2) && req[:path] != dashboard_users_path
    if (step == 3) && req[:path] != new_dashboard_user_path && req[:get]
      path = new_dashboard_user_path
    end

    if step == 4 && req[:path] != operators_path && params[:availability] != 'common'  && req[:get]
      path = operators_path(availability: 'common')
    end

    if step == 5 && (req[:path] != operators_path || params[:availability] == 'common') && req[:get]
      path = operators_path
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

    if step == 3
      if user && user.errors.count == 0
        self.step = step + 1
        self.save
      end
    end

  end
end
