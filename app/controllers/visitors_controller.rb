class VisitorsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        @visitor = Visitor.new(params['visitor'])
        if @visitor.save
          Mailer.visitor_confirmation(@visitor).deliver
          render :json => {:success => true, :message => I18n.t('devise.registrations.user.signed_up_but_unconfirmed')}
        else
          errors = {}
          @visitor.errors.messages.each do |key, value|
            errors[key] = @visitor.errors.full_message(key, value[0])
          end
          render :json => {:success => false, :errors => errors }
        end
      end
    end
  end

  def confirm
    @visitor = Visitor.where(confirmation_token: params[:confirmation_token]).first
    if @visitor
      if !@visitor.confirmed?
        @visitor.confirm
      end
      sign_in :user, User.where(login: 'demo').first
      cookie_key = (CONFIG[:session_key] + '_visitor').to_sym
      cookies[cookie_key] = {
        value: @visitor.id,
        domain: '.' + CONFIG[:domain],
        expires: 1.year.from_now # infinite cookie
      }
      redirect_to root_path
    else
      flash[:alert] = I18n.t('devise.sessions.user.demo_reg', :href => CONFIG[:domain] + '/#visitor')
      redirect_to new_user_session_path
    end
  end
end
