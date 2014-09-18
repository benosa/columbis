class StartTrip < ActiveRecord::Base
 # include ActiveSupport::Configurable
 # include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  attr_accessible :step, :user_id

  belongs_to :user

  def check_step_actions_path(req, params = [], step_c = false)
    path = false

    if params['action'] != 'current_timestamp' && params['controller'] != 'claims_autocomplete'
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
      elsif step == 5 && step_c == 5
        inc_step
      end

      if (step == 6 || step == 10 || step == 12) && req[:get] && req[:path] != new_claim_path
        path = new_claim_path
      end

      if step == 7 && req[:get] && req[:path] != claims_path &&
      (params['controller'] == 'claims' && params['action'] != 'edit')
        path = claims_path
      elsif step == 7 && step_c == 7
        inc_step
      end

      if step == 8
        claim = Claim.where(user_id: user.id).first
        if req[:get] && req[:path] != edit_claim_path(claim)
          path = edit_claim_path(claim)
        end
      end

      if (step == 9 || step == 11) && req[:get] && req[:path] != claims_path && req[:path] != new_claim_path
        path = claims_path
      elsif (step == 9 && step_c == 9 || step == 11 && step_c == 11)
        inc_step
      end

      if step == 13 && step_c == 0 && req[:get] && (req[:path] != claims_path ||
      params['controller'] == 'claims' && params['action'] != 'index')
        path = claims_path
      elsif step == 13 && step_c == 13
        inc_step
      end

      if step == 14 && req[:get] && req[:path] != new_tourist_path &&
      (req[:path] != tourists_path || params[:potential] != 'true')
        path = tourists_path(potential: true)
      elsif step == 14 && step_c == 14
        inc_step
      end

      if step == 15 && req[:get] && (req[:path] != new_tourist_path || params[:potential] != 'true')
        path = new_tourist_path(potential: true)
      end
    end

    path
  end

  def check_step_actions_cookie(step_c, company, user, claim, tourist)
    if step_c == 1
      if company && company.errors.count == 0
        inc_step
      end
    end

    if step_c == 2 || step_c == 4
      inc_step
    end

    if step_c == 3
      if user && user.errors.count == 0
        inc_step
      end
    end

    if step_c == 6 || step_c == 8 || step_c == 10 || step_c == 12
      if claim && claim.errors.count == 0
        inc_step
      end
    end

    if step_c == 15
      if tourist && tourist.errors.count == 0
        inc_step
      end
    end

  end

  def inc_step
    self.step = step + 1
    self.save
  end
end
