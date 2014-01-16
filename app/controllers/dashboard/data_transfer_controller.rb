class Dashboard::DataTransferController < ApplicationController

  def export
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    @totals = Claim.accessible_by(current_ability).includes(inluded_tables)

    @tourists = Tourist.accessible_by(current_ability).includes([:address, :user])

    @clients = Tourist.accessible_by(current_ability).includes(:address).potentials

    @managers = User.where(:company_id => current_company.id)

    @operators = Operator.by_company_or_common(current_company).includes(:address)

    @tourists_payments = Payment.where(:company_id => current_company.id, :payer_type => 'Tourist').order('date_in desc')

    @operator_payments = Payment.where(:company_id => current_company.id, :recipient_type => 'Operator').order('date_in desc')

    respond_to do |format|
      format.xls { render "claims" }
    end
  end

  def import
    filename = "/home/ololo/rails_proj/columb/devmen_tourism/public/#{params[:filename]}"
    import_new = ImportInfo.new(filename: filename)
    import_new.company = current_company
    import_new.save
    importing = Import::Formats::XLS.new([:client, :operator, :tourist, :claim, :payment_operator, :payment_tourist], filename, current_company.id, import_new.id)
  #  importing = Import::Formats::XLS.new([:claim], filename, current_company.id, import_new.id)
    importing.start

    claim_ids = ImportItem.select(:model_id).where(model_class: 'Claim', import_info_id: import_new.id).all.map { |c| c.model_id }
    if claim_ids
      Claim.find(claim_ids).each do |cl|
        cl.save
      end
    end
    render :json => {:success => 'ololo'}
  end

end
