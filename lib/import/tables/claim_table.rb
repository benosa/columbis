module Import
  module Tables
    module ClaimTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :date                   => {:type => 'Date',   :may_nil => false, :value => Time.zone.now},
          :promotion              => {:type => 'String', :may_nil => false, :value => 'Другое'},
          :user                   => {:type => 'String', :may_nil => false, :value => nil},
          :office                 => {:type => 'String', :may_nil => false, :value => nil},
          :tourist                => {:type => 'String', :may_nil => false, :value => nil},
          :telephone              => {:type => 'String', :may_nil => false, :value => nil},
          :passport_number        => {:type => 'String', :may_nil => false, :value => nil},
          :passport_series        => {:type => 'String', :may_nil => false, :value => nil},
          :email                  => {:type => 'String', :may_nil => true,  :value => nil},
          :date_of_birth          => {:type => 'Date',   :may_nil => false, :value => nil},
          :passport_valid_until   => {:type => 'Date',   :may_nil => false, :value => nil},
          :arrival_date           => {:type => 'Date',   :may_nil => false, :value => nil},
          :departure_date         => {:type => 'Date',   :may_nil => false, :value => nil},
          :country                => {:type => 'String', :may_nil => false, :value => nil},
          :airport_back           => {:type => 'String', :may_nil => false, :value => nil},
          :visa                   => {:type => 'String', :may_nil => true,  :value => 'Виза не нужна'},
          :visa_check             => {:type => 'Date',   :may_nil => true,  :value => nil},
          :operator               => {:type => 'String', :may_nil => false, :value => nil},
          :operator_number        => {:type => 'String', :may_nil => true,  :value => nil},
          :operator_series        => {:type => 'String', :may_nil => true,  :value => nil},
          :operator_confirmation  => {:type => 'String', :may_nil => true,  :value => nil},
          :primary_currency_price => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_price         => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_maturity      => {:type => 'Date',   :may_nil => true,  :value => nil},
          :operator_paid          => {:type => 'Float',  :may_nil => true,  :value => nil},
          :tourist_advance        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :documents_status       => {:type => 'String', :may_nil => true, :value => 'Не готовы'},
          :docs_note              => {:type => 'String', :may_nil => true,  :value => ''},
          :check_date             => {:type => 'Date',   :may_nil => false, :value => Time.zone.now}
        }

      class << self
        def columns_count
          29
        end

        def sheet_number
          1
        end

        def import(row, company)
          puts "    Start import row: #{row.to_s}"
          data_row = prepare_data(row, company)
          if data_row
            claim = Claim.new
            claim.company = company
            if claim.assign_reflections_and_save(create_claim_params(data_row, company))
              puts "    Claim was importing"
              true
            else
              puts "    Claim not save"
              false
            end
          else
            puts "    Row invalid"
            false
          end
        end

        private

        def prepare_data(row, company)
          data_row = type_check(row)
          fields_check(data_row, company)
          puts "    Fields check complete."
          data_row = check_for_nil(data_row)
          puts "    Check for nil complete."
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
            data_row[key][:value] = field.blank? ? nil : field
          end
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
          tourist =
            unless tourist
              Tourist.new do |t|
                t.full_name = row[:tourist][:value]
                t.company_id = company.id
                t.passport_series = row[:passport_series][:value]
                t.passport_number = row[:passport_number][:value]
                t.passport_valid_until = row[:passport_valid_until][:value]
                t.date_of_birth = row[:date_of_birth][:value]
                t.email = row[:email][:value]
                t.phone_number = row[:telephone][:value]
              end
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
            row[:documents_status][:value] = documents_statuses[row[:visa][:value]]
          else
            row[:documents_status][:value] = nil
          end
        end

        def create_claim_params(row, company)
          {
            "user_id" => row[:user][:value],
            "office_id" => row[:office][:value],
            "reservation_date" => row[:date][:value],
            "check_date" => row[:check_date][:value],
            "tourist_stat" => row[:promotion][:value],
            "arrival_date" => row[:arrival_date][:value],
            "departure_date" => row[:departure_date][:value],
            "applicant_attributes" => row[:tourist][:value],
            "visa" => row[:visa][:value],
            "visa_check" => row[:visa_check][:value],
            "primary_currency_price" => row[:primary_currency_price][:value],
            "operator_confirmation_flag"=>"0",
            "closed"=>"0",
            "operator_confirmation" => row[:operator_confirmation][:value],
            "operator_price" => row[:operator_price][:value],
            "operator_maturity" => row[:operator_maturity][:value],
            "operator_paid" => row[:operator_paid][:value],
            "docs_note" => row[:docs_note][:value],
            "tourist_advance" => row[:tourist_advance][:value],
            "documents_status" => row[:documents_status][:value],
            "country" => { "name" => row[:country][:value] }
          }
        end
      end
    end
  end
end