module Import
  module Tables
    class PaymentTouristTable# < Tables::DefaultTable
       extend Tables::DefaultTable

      FORMAT =
        {
          :claim_num               => {:type => 'Int', :may_nil => false, :value => nil},
          :date_in                 => {:type => 'Date', :may_nil => false, :value => nil},
          :currency                => {:type => 'Float', :may_nil => true, :value => nil},
          :amount                  => {:type => 'Int', :may_nil => true, :value => nil},
          :description             => {:type => 'String', :may_nil => true, :value => nil},
          :form                    => {:type => 'String', :may_nil => true, :value => nil},
          :amount_prim             => {:type => 'Int', :may_nil => true, :value => nil},
          :approved                => {:type => 'String', :may_nil => true, :value => nil},
          :course                  => {:type => 'String', :may_nil => true, :value => nil},
          :reversed_course          => {:type => 'String', :may_nil => true, :value => nil}
        }

     # class << self
        def self.columns_count
          10
        end

        def self.sheet_number
          4
        end

        def import(row, company, import_new)
          puts "Start import Operator"
          puts row.to_s

          data_row = prepare_data(row, company)

          params = create_payment_params(data_row, company)
         # if (!check_exist(params, company))
            payment = Payment.new(params)
            claim = find_claim(data_row[:claim_num][:value], company)
            payment.company = company
            payment.claim = claim
            payment.payer_type = 'Tourist'
            payment.recipient_type = 'Company'
            payment.payer_id = claim.applicant.id
            payment.recipient_id = company.id
            info_params = { model_class: 'Payment' }
            if payment.save
              info_params[:model_id] = payment.id
             # if data_row[:address][:value]
             #   operator.create_address(company_id: company.id, joint_address: data_row[:address][:value] )
             # end
              puts "Payment was importing"
              true
            else
              puts payment.errors.inspect
              Rails.logger.debug "url_for_current_company: #{payment.errors.inspect}"
              puts "Payment not save"
              false
            end
            DefaultTable.save_import_item(info_params, import_new)
         # else
         #   puts "Operator exist"
         # end
        end

        private

       # def update_claims

        def prepare_data(row, company)
          data_row = Marshal.load(Marshal.dump(FORMAT))
            row.each_with_index do |field, i|
            key = data_row.keys[i]
            data_row[key][:value] = field unless field.blank?
          end
          data_row
        end

        def find_claim(num, company)
          Claim.where(:company_id => company.id, :num => num).first
        end

       # def check_exist(params, company)
       #   operator = Operator.where(name: params[:name], company_id: company.id).first
       #   operator
       # end

        def create_payment_params(row, company)
          {
            :date_in                 => row[:date_in][:value],
            :currency                => row[:currency][:value],
            :amount                  => row[:amount][:value],
            :description             => row[:description][:value],
            :form                    => row[:form][:value],
            :amount_prim             => row[:amount_prim][:value],
            :approved                => row[:approved][:value],
            :course                  => row[:course][:value],
            :reversed_course         => row[:reversed_course][:value]
          }
        end
     # end
    end
  end
end