class VisitorsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        @visitor = Visitor.new(params['visitor'])
        @
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
  end
end
