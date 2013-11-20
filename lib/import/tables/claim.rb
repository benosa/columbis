module Import
  module Tables
    module Claim
      extend Tables::DefaultTable

      FORMAT =
        {
          :date                   => {:type => 'Date',   :may_nil => false, :value => Time.zone.now},
          :promotion              => {:type => 'String', :may_nil => false, :value => 'Другое'},
          :user                   => {:type => 'String', :may_nil => false, :value => nil},
          :office                 => {:type => 'String', :may_nil => false, :value => nil},
          :full_name              => {:type => 'String', :may_nil => false, :value => nil},
          :telephone              => {:type => 'String', :may_nil => false, :value => nil},
          :pasport_number         => {:type => 'String', :may_nil => false, :value => nil},
          :pasport_series         => {:type => 'String', :may_nil => false, :value => nil},
          :email                  => {:type => 'String', :may_nil => true,  :value => nil},
          :date_of_birht          => {:type => 'Date',   :may_nil => false, :value => nil},
          :pasport_valid_until    => {:type => 'Date',   :may_nil => false, :value => nil},
          :arrival_date           => {:type => 'Date',   :may_nil => false, :value => nil},
          :departure_date         => {:type => 'Date',   :may_nil => false, :value => nil},
          :country                => {:type => 'String', :may_nil => false, :value => nil},
          :airport_back           => {:type => 'String', :may_nil => false, :value => nil},
          :visa                   => {:type => 'String', :may_nil => false, :value => 'Виза не нужна'},
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
          :documents_status       => {:type => 'String', :may_nil => false, :value => 'Не готовы'},
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
          puts "Start import"
          data_row = check(row, company)
          if data_row
            claim = create_claim(data_row, company)
            if claim.save
              # need add flights
              # need add operator
              puts "Claim was importing"
              true
            else
              puts "Claim not save"
              false
            end
          else
            puts "Row can't check"
            false
          end
        end

        private

        def check(row, company)
          data_row = type_check(row)
          if data_row
            puts "Type check complete."
            fields_check(data_row, company)
            puts "Fields check complete."
            check_for_nil(data_row)
            puts "Check for nil complete."
            data_row
          else
            puts "Type check not complete"
            false
          end
        end

        def type_check(row)
          data_row = FORMAT.dup
          row.each_with_index do |field, i|
            key = data_row.keys[i]
            # This ifelse needs to get round the roo bug
            if data_row[key][:type] == "String" && field.class.to_s == "Float"
              data_row[key][:value] = field.to_i.to_s unless field.nil?
            else
              if field.nil? || field.class.to_s == data_row[key][:type]
                data_row[key][:value] = field unless field.nil?
              else
                puts "Type check error in key '#{key}' in row: #{row.to_s}."
                return false
              end
            end
          end
          data_row
        end

        def fields_check(row, company)
          row.each do |field|
            if private_instance_methods.include?("#{field[0]}_check")
              send("#{field[0]}_check", row, company)
            end
          end
        end

        def check_for_nil(row)
          row.each do |field|
            return false if row[field[0]][:value].nil? && !row[field[0]][:may_nil]
          end
          true
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

        def full_name_check(row, company)
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
                t.full_name = row.delete(:full_name)[:value]
                t.passport_series = row.delete(:passport_series)[:value]
                t.passport_number = row.delete(:passport_number)[:value]
                t.passport_valid_until = row.delete(:passport_valid_until)[:value]
                t.date_of_birth = row.delete(:date_of_birth)[:value]
                t.email = row.delete(:email)[:value]
                t.phone_number = row.delete(:telephone)[:value]
              end
            end
          if tourist.id || tourist.valid?
            row.merge!({:tourist => {:value => tourist.attributes, :may_nil => false}})
          else
            row.merge!({:tourist => {:value => nil, :may_nil => false}})
          end
        end

        def operator_check(row, company)
          operator =
            if row[:operator_number][:value] != nil && row[:operator_series][:value] != nil
              Operator.where(:company_id => company.id)
                .where("operator_number = '#{row[:operator_number][:value]}'")
                .where("operator_series = '#{row[:operator_series][:value]}'")
                .first
            end
          operator =
            unless operator
              Operator.new do |o|
                o.name = row.delete(:operator)[:value]
                o.operator_number = row.delete(:operator_number)[:value]
                o.operator_series = row.delete(:operator_series)[:value]
                o.operator_confirmation = row.delete(:operator_confirmation)[:value]
              end
            end
          if operator.id || operator.valid?
            row.merge!({:operator => {:value => operator.attributes, :may_nil => false}})
          else
            row.merge!({:operator => {:value => nil, :may_nil => false}})
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

        # def check_field(field, value)
        #   if value.nil?
        #     false || field[:may_nil]
        #   else
        #     field[:value] = value
        #   end
        # end

        def create_claim(row, company)
          puts "Create this row before create claim: #{row.to_s}"
          claim = Rails::Application::Claim.new do |c|
            c.company_id = company
            c.user_id = row[:user][:value]
            c.office_id = row["office"][:value]
            c.reservation_date = row[:date][:value]
            c.check_date = row[:check_date][:value]
            c.tourist_stat = row[:promotion][:value]
            c.arrival_date = row[:arrival_date][:value]
            c.departure_date = row[:departure_date][:value]
            c.country = row[:country][:value]
            c.applicant_attributes = row[:tourist][:value]
            c.visa = row[:visa][:value]
            c.visa_check = row[:visa_check][:value]
            c.applicant_attributes = row[:tourist][:value]
            c.primary_currency_price = row[:primary_currency_price][:value]
            c.operator_price = row[:operator_price][:value]
            c.operator_maturity = row[:operator_maturity][:value]
            c.operator_paid = row[:operator_paid][:value]
            c.docs_note = row[:docs_note][:value]
            c.tourist_advance = row[:tourist_advance][:value]
          end
        end
      end
    end
  end
end