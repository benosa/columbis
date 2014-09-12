class StartTrip < ActiveRecord::Base
 # include ActiveSupport::Configurable
 # include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  attr_accessible :step, :user_id

  belongs_to :user

  def check_step_actions_path(req, params = [], step_c = false)
    path = false
    path = dashboard_users_path if (step == 2) && req[:path] != dashboard_users_path
    if (step == 3) && req[:path] != new_dashboard_user_path && req[:get]
      path = new_dashboard_user_path
    end

    if step == 4 && req[:path] != operators_path && params[:availability] != 'common'  && req[:get]
      path = operators_path(availability: 'common')
    end

    if step == 5 && req[:get] && req[:path] != new_claim_path &&
    (req[:path] != operators_path || params[:availability] == 'common')
      path = operators_path
    end

    if (step == 6 || step == 9 || step == 11) && req[:get] && req[:path] != new_claim_path
      path = new_claim_path
    end

    if step == 7 && req[:get] && (req[:path] != claims_path ||
    params['controller'] == 'claims' && params['action'] != 'edit')
      path = claims_path
    end

    if (step == 8 || step == 10) && req[:get] && req[:path] != claims_path && req[:path] != new_claim_path
      path = claims_path
    end

    if step == 12 && step_c == 0 && req[:get] && (req[:path] != claims_path ||
    params['controller'] == 'claims' && params['action'] != 'index')
      path = claims_path
    end

    if step == 13 && req[:get] && (req[:path] != tourists_path || params[:potential] != 'true')
      path = tourists_path(potential: true)
    end

    path
  end

  def check_step_actions_cookie(step, company, user, claim)
    if step == 1
      if company && company.errors.count == 0
        self.step = 2
        self.save
      end
    end

    if step == 2 || step == 4 || step == 5 || step == 8 || step == 10 || step == 12
      self.step = step + 1
      self.save
    end

    if step == 3
      if user && user.errors.count == 0
        self.step = step + 1
        self.save
      end
    end

    if step == 6 || step == 7 || step == 9 || step == 11
      if claim && claim.errors.count == 0
        self.step = step + 1
        self.save
      end
    end

  end
end
