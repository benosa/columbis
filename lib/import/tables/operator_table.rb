module Import
  module Tables
    module OperatorTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :name                    => {:type => 'String', :may_nil => false, :value => nil},
          :full_name               => {:type => 'String', :may_nil => true, :value => nil},
          :register_number         => {:type => 'String', :may_nil => true, :value => nil},
          :register_series         => {:type => 'String', :may_nil => true, :value => nil},
          :inn                     => {:type => 'String', :may_nil => true, :value => nil},
          :ogrn                    => {:type => 'String', :may_nil => true, :value => nil},
          :code_of_reason          => {:type => 'String', :may_nil => true, :value => nil},
          :phone_numbers           => {:type => 'String', :may_nil => true, :value => nil},
          :site                    => {:type => 'String', :may_nil => true, :value => nil},
          :banking_details         => {:type => 'String', :may_nil => true, :value => nil},
          :actual_address          => {:type => 'String', :may_nil => true, :value => nil},
          :address                 => {:type => 'String', :may_nil => true, :value => nil},
          :insurer                 => {:type => 'String', :may_nil => true, :value => nil},
          :insurer_full_name       => {:type => 'String', :may_nil => true, :value => nil},
          :insurer_address         => {:type => 'String', :may_nil => true, :value => nil},
          :actual_insurer_address  => {:type => 'String', :may_nil => true, :value => nil},
          :insurer_provision       => {:type => 'Float', :may_nil => true, :value => nil},
          :insurer_contract        => {:type => 'String', :may_nil => true, :value => nil},
          :insurer_contract_date   => {:type => 'Date',   :may_nil => true, :value => nil},
          :insurer_contract_start  => {:type => 'Date',   :may_nil => true, :value => nil},
          :insurer_contract_end    => {:type => 'Date',   :may_nil => true, :value => nil}
        }

      class << self
        def columns_count
          21
        end

        def sheet_number
          3
        end

        def import(row, company)
          puts "    Start import row."
         # puts row.inspect
          data_row = prepare_data(row, company)
        #  puts data_row.inspect
          if data_row
            params = create_operator_params(data_row, company)
           # operator = Operator.new(params)
           puts params.inspect

          #  if operator.save
          #    puts "    Operator was importing"
          #    true
          #  else
          #    puts operator.errors.inspect
          #    puts "    Operator not save"
            #  false
          #  end
          else
            puts "    Row invalid"
            false
          end
        end

        private

        def prepare_data(row, company)
          data_row = type_check(row)
         # puts data_row.inspect
         # fields_check(data_row, company)
         #  puts data_row.inspect
        #  puts "    Fields check complete."
         # data_row = check_for_nil(data_row)
          # puts data_row.inspect
         # puts "    Check for nil complete."
          data_row
        end

        def type_check(row)
          data_row = FORMAT.dup
          row.each_with_index do |field, i|
            key = data_row.keys[i]
            if data_row[key][:type] == "String" && field.class.to_s == "Float"
              field = field.to_i.to_s
            else
              field = field.to_s
            end
            data_row[key].delete(:type)
            data_row[key][:value] = field unless field.blank?
          end
       #   puts data_row.to_s
          data_row
        end

        def fields_check(row, company)
          row.each do |field|
            if private_methods.include?("#{field[0]}_check".to_sym)
              send("#{field[0]}_check".to_sym, row, company)
            end
          end
        end

        def check_for_nil(row)
          row.each do |field|
            return false if row[field[0]][:value].nil? && !row[field[0]][:may_nil]
            row[field[0]] = row[field[0]][:value]
          end
          row
        end

        def user_check(row, company)
          user = company.users.where(:login => row[:user][:value]).first
          row[:user][:value] = user.try(:id)
        end

        def office_check(row, company)
          office = company.offices.where(:name => row[:office][:value]).first
          office = company.offices.first if office.nil?
          row[:office][:value] = office.try(:id)
        end

        def tourist_check(row, company)
          tourist =
            if row[:passport_series][:value] != nil && row[:passport_number][:value] != nil
              Tourist.where(:company_id => company.id)
                .where("passport_series = '#{row[:passport_series][:value]}'")
                .where("passport_number = '#{row[:passport_number][:value]}'")
                .first
            end
          unless tourist
            tourist = Tourist.new do |t|
              t.full_name = row[:tourist][:value]
              t.passport_series = row[:passport_series][:value]
              t.passport_number = row[:passport_number][:value]
              t.passport_valid_until = row[:passport_valid_until][:value]
              t.date_of_birth = row[:date_of_birth][:value]
              t.email = row[:email][:value]
              t.phone_number = row[:telephone][:value]
            end
            tourist.company_id = company.id
          end
          if tourist.id || tourist.valid?
            row[:tourist] = {:value => tourist.attributes, :may_nil => false}
          else
            row[:tourist] = {:value => nil, :may_nil => false}
          end
        end

        def operator_check(row, company)
          operator =
            if row[:operator_number][:value] != nil && row[:operator_series][:value] != nil
              Operator.where(:company_id => company.id)
                .where("register_number = '#{row[:operator_number][:value]}'")
                .where("register_series = '#{row[:operator_series][:value]}'")
                .first
            end
          operator =
            unless operator
              Operator.new do |o|
                o.name = row[:operator][:value]
                o.register_number = row[:operator_number][:value]
                o.register_series = row[:operator_series][:value]
              end
            end
          if operator.id || operator.valid?
            row[:operator] = {:value => operator.attributes, :may_nil => false}
          else
            row[:operator] = {:value => nil, :may_nil => false}
          end
        end

        def visa_check(row, company)
          visa_statuses = {}
          Claim::VISA_STATUSES.each do |status|
            visa_statuses.merge!({ I18n.t(".claims.visa_statuses.#{status}") => status })
          end
          if visa_statuses.keys.include?(row[:visa][:value])
            row[:visa][:value] = visa_statuses[row[:visa][:value]]
          else
            row[:visa][:value] = nil
          end
        end

        def documents_status_check(row, company)
          documents_statuses = {}
          Claim::DOCUMENTS_STATUSES.each do |status|
            documents_statuses.merge!({ I18n.t(".claims.documents_statuses.#{status}") => status })
          end
          if documents_statuses.keys.include?(row[:documents_status][:value])
            row[:documents_status][:value] = documents_statuses[row[:documents_status][:value]]
          else
            row[:documents_status][:value] = nil
          end
        end

        def create_operator_params(row, company)
          {

            "name" => row[:name][:value],
            "full_name" => row[:full_name][:value],
            "register_number" => row[:register_number][:value],
            "register_series" => row[:register_series][:value],
            "inn" => row[:inn][:value],
            "ogrn" => row[:ogrn][:value],
            "code_of_reason" => row[:code_of_reason][:value],
            "phone_numbers" => row[:phone_numbers][:value],
            "site" => row[:site][:value],
            "banking_details"=>row[:banking_details][:value],
            "actual_address" => row[:actual_address][:value],
            "insurer" => row[:insurer][:value],
            "insurer_full_name" => row[:insurer_full_name][:value],
            "insurer_address" => row[:insurer_address][:value],
            "actual_insurer_address" => row[:actual_insurer_address][:value],
            "insurer_provision" => row[:insurer_provision][:value],
            "insurer_contract" => row[:insurer_contract][:value],
            "insurer_contract_date" => row[:insurer_contract_date][:value],
            "insurer_contract_start" => row[:insurer_contract_start][:value],
            "insurer_contract_end" => row[:insurer_contract_end][:value]
            # "payments_in_attributes" => {
            #   "0"=>{
            #     "date_in"=>"",
            #     "amount"=>row[:tourist_advance],
            #     "approved"=>"0",
            #     "form"=>"",
            #     "_destroy"=>"false",
            #     "id"=>""
            #   }
            # },
            # "operator_price_currency"=>"rur",
            # "payments_out_attributes" => {
            #   "0"=>{
            #     "date_in"=>row[:operator_maturity],
            #     "amount_prim"=>"0.0",
            #     "course"=>"",
            #     "amount"=>row[:operator_paid],
            #     "approved"=>"1",
            #     "form"=>"",
            #     "_destroy"=>"false",
            #     "id"=>""
            #   }
            # },
            # "assistant_id"=>"",
            # "early_reservation"=>"0",
            # "canceled"=>"0",
            # "excluded_from_profit"=>"0",
            # "course_eur"=>"0",
            # "course_usd"=>"0",
            # "tour_price_currency"=>"rur",
            # "tour_price"=>row[:primary_currency_price],
            # "visa_count"=>"0",
            # "visa_price_currency"=>"rur",
            # "visa_price"=>"0",
            # "children_visa_count"=>"0",
            # "children_visa_price_currency"=>"rur",
            # "children_visa_price"=>"0",
            # "insurance_count"=>"0",
            # "insurance_price_currency"=>"rur",
            # "insurance_price"=>"0",
            # "additional_insurance_count"=>"0",
            # "additional_insurance_price_currency"=>"rur",
            # "additional_insurance_price"=>"0",
            # "fuel_tax_count"=>"0",
            # "fuel_tax_price_currency"=>"rur",
            # "fuel_tax_price"=>"0",
            # "additional_services_price_currency"=>"rur",
            # "additional_services_price"=>"0"
          }
        end
      end
    end
  end
end