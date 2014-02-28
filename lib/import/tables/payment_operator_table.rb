module Import
  module Tables
    class PaymentOperatorTable < Tables::PaymentTouristTable
      #extend Tables::PaymentTouristTable

     # class << self

       # include Tables::PaymentTouristTable

        def self.sheet_number
          5
        end

        def import(row, company, import_new, line)
          puts "Start import Payment"
          puts row.to_s

          data_row = prepare_data(row, company)

          params = create_payment_params(data_row, company)
         # if (!check_exist(params, company))
            payment = Payment.new(params)
            claim = find_claim(data_row[:claim_num][:value], company)
            if claim
              payment.company = company
              payment.claim = claim
              payment.payer_type = 'Company'
              payment.recipient_type = 'Operator'
              payment.payer_id = company.id
              payment.recipient_id = claim.operator.id if claim.operator
            end
            info_params = { model_class: 'Payment', file_line: line, success:false }
            if payment.save
              info_params[:model_id] = payment.id
              info_params[:success] = true
             # if data_row[:address][:value]
             #   operator.create_address(company_id: company.id, joint_address: data_row[:address][:value] )
             # end
              puts "Payment was importing"
              true
            else
             # puts payment.errors.inspect
              info_params[:data] = payment.errors.messages.to_yaml
             # Rails.logger.debug "url_for_current_company: #{payment.errors.inspect}"
            #  puts "Payment not save"
              false
            end
            DefaultTable.save_import_item(info_params, import_new)
         # else
         #   puts "Operator exist"
         # end
        end

     # end
    end
  end
end