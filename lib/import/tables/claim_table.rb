module Import
  module Tables
    module ClaimTable
      extend Tables::DefaultTable

         <Cell><Data ss:Type="Number"><%= claim.num %></Data></Cell>
        <Cell ss:StyleID="<%= row_date_style %>"><%= excel_date claim.reservation_date %></Cell>
        <Cell><Data ss:Type="String"><%= claim.tourist_stat %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.office.name %></Data></Cell>
        <%= excel_element "Cell", "users-#{claim.user.id}", styles %>
          <Data ss:Type="String"><%= claim.user.login %></Data></Cell>
        <Cell><Data ss:Type="String"><%= tourists_list(claim) %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.applicant.try(:phone_number) %></Data></Cell>
        <% if claim.canceled? %>
        <Cell ss:StyleID="companies-dates-gray_back">
        <% else %>
        <%= excel_element "Cell", "companies-dates-#{color_for_flight(claim)}", styles %>
        <% end %>
          <%= excel_date claim.arrival_date %></Cell>
        <% if claim.canceled? %>
          <Cell ss:StyleID="companies-dates-gray_back">
        <% else %>
          <Cell ss:StyleID="<%= color_for_departure_date_call(claim).to_s != '' ? "companies-dates-#{color_for_departure_date_call(claim)}" : "date" %>">
        <% end %>
          <%= excel_date claim.departure_date %></Cell>
        <Cell><Data ss:Type="String"><%= claim.country.try(:name) %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.city.try(:name) %></Data></Cell>
        <%= excel_element "Cell", "companies-#{color_for_visa(claim)}", styles %>
          <Data ss:Type="String"><%= text_for_visa(claim) %></Data></Cell>
        <% if claim.canceled? %>
        <Cell ss:StyleID="companies-dates-gray_back">
        <% else %>
        <%= excel_element "Cell", "companies-dates-#{color_for_visa(claim)}", styles %>
        <% end %>
          <%= excel_date claim.visa_check %></Cell>
        <Cell><Data ss:Type="String"><%= claim.operator.try(:name) %></Data></Cell>
        <%= excel_element "Cell", "companies-red_back", styles, (!claim.canceled? && !claim.operator_confirmation_flag) %>
          <Data ss:Type="String"><%= claim.operator_confirmation %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= claim.primary_currency_price.to_money %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.calculation %></Data></Cell>
        <%= excel_element "Cell", "companies-#{color_for_tourist_advance(claim)}", styles %>
          <Data ss:Type="Number"><%= claim.tourist_advance.to_money %></Data></Cell>
        <%= excel_element "Cell", "companies-#{color_for_tourist_advance(claim)}", styles %>
          <Data ss:Type="Number"><%= claim.tourist_debt.to_money %></Data></Cell>
        <%= excel_element "Cell", "companies-#{color_for_operator_price(claim)}", styles %>
          <Data ss:Type="String"><%= operator_price(claim) %></Data></Cell>
        <Cell ss:StyleID="<%= row_date_style %>"><%= excel_date claim.operator_maturity %></Cell>
        <Cell><Data ss:Type="String"><%= operator_advance(claim) %></Data></Cell>
        <%= excel_element "Cell", "companies-#{color_for_operator_debt(claim)}", styles %>
          <Data ss:Type="String"><%= operator_debt(claim) %></Data></Cell>
        <%= excel_element "Cell", "companies-red_back", styles, (claim.approved_tourist_advance < claim.primary_currency_price) %>
          <Data ss:Type="String"><%= approved_advance(claim, :tourist) %></Data></Cell>
        <Cell><Data ss:Type="String"><%= approved_advance(claim, :operator_prim) %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= approved_advance(claim, :operator) %></Data></Cell>
        <%= excel_element "Cell", "companies-red_back", styles, (claim.profit_acc < 0 && !claim.excluded_from_profit) %>
          <Data ss:Type="Number"><%= claim.profit_acc.to_money %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= claim.profit_in_percent_acc.to_percent unless claim.excluded_from_profit %></Data></Cell>
        <%= excel_element "Cell", "companies-red_back", styles, (claim.profit < 0 && !claim.excluded_from_profit) %>
          <Data ss:Type="Number"><%= claim.profit.to_money %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= claim.profit_in_percent.to_percent unless claim.excluded_from_profit %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= claim.bonus_percent.to_percent %></Data></Cell>
        <Cell><Data ss:Type="Number"><%= claim.bonus.to_money %></Data></Cell>
        <Cell><Data ss:Type="String"><%= t('claims.documents_statuses.' << claim.documents_status) %></Data></Cell>
        <%= excel_element "Cell", "companies-red_back", styles, (!claim.memo_tasks_done and claim.memo != '') %>
          <Data ss:Type="String"><%= claim.memo %></Data></Cell>
        <% if claim.canceled? %>
        <Cell ss:StyleID="companies-dates-gray_back">
        <% else %>
        <%= excel_element "Cell", "companies-dates-#{check_date_status(claim)}", styles %>
        <% end %>
          <%= excel_date claim.check_date %></Cell>
        <Cell><Data ss:Type="String"><%= claim.early_reservation ? 'Да' : 'Нет' %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.excluded_from_profit ? 'Да' : 'Нет' %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.canceled ? 'Да' : 'Нет' %></Data></Cell>
        <Cell><Data ss:Type="String"><%= claim.active ? 'Да' : 'Нет' %></Data></Cell>

      FORMAT =
        {
          :num                    => {:type => 'Int',   :may_nil => false, :value => nil},
          :reservation_date       => {:type => 'Date',   :may_nil => false, :value => Time.zone.now},
          :tourist_stat           => {:type => 'String', :may_nil => false, :value => 'Другое'},
          :office                 => {:type => 'String', :may_nil => false, :value => nil},
          :user                   => {:type => 'String', :may_nil => false, :value => nil},
          :tourist                => {:type => 'String', :may_nil => false, :value => nil},
          :phone_number           => {:type => 'String', :may_nil => false, :value => nil},
          :arrival_date           => {:type => 'Date',   :may_nil => false, :value => nil},
          :departure_date         => {:type => 'Date',   :may_nil => false, :value => nil},
          :country                => {:type => 'String', :may_nil => false, :value => nil},
          :city                   => {:type => 'String', :may_nil => true,  :value => nil},
          :visa                   => {:type => 'String', :may_nil => true,  :value => 'Виза не нужна'},
          :visa_check             => {:type => 'Date',   :may_nil => true,  :value => nil},
          :operator               => {:type => 'String', :may_nil => false, :value => nil},
          :operator_confirmation  => {:type => 'String', :may_nil => true,  :value => nil},
          :primary_currency_price => {:type => 'Float',  :may_nil => true,  :value => nil},
          :calculation            => {:type => 'String', :may_nil => true,  :value => nil},
          :tourist_advance        => {:type => 'String', :may_nil => false, :value => nil},
          :tourist_debt        => {:type => 'String', :may_nil => false, :value => nil},
          :operator_price         => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_maturity      => {:type => 'Date',   :may_nil => true,  :value => nil},
          :operator_advance       => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_debt          => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_tourist_advance        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_operator_advance        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_operator_advance_prim        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_acc        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_in_percent_acc        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_in_percent        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :bonus_percent        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :bonus        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :documents_status       => {:type => 'String', :may_nil => true,  :value => 'Не готовы'},
          :docs_note              => {:type => 'String', :may_nil => true,  :value => ''},
          :check_date             => {:type => 'Date',   :may_nil => false, :value => Time.zone.now}
        }

      class << self
        def columns_count
          35
        end

        def sheet_number
          1
        end

        def import(row, company)
          puts "    Start import row."
          data_row = prepare_data(row, company)
          if data_row && !data_row[:cant_be_nil]
            params = create_claim_params(data_row, company)
            claim = Claim.new(params)
            claim.company = company
            claim.user_id = data_row[:user]
            claim.office_id = data_row[:office]
            tourists = parse_tourists(data_row)
            claim.applicant = tourist_check(tourists[0], company) if tourists[0]
            if claim.assign_reflections_and_save(params)
              puts "    Claim was importing"
              true
            else
              puts claim.errors.inspect
              puts "    Claim not save"
              false
            end
          else
            puts " #{data_row[:cant_be_nil]} empty"
            false
          end
        end

        private

        def parse_tourists(row)
          tourists = []
          row[:tourist][:value].split(',').each do |tourist|
            tourist_split = tourist.split(' ')
            tourists << { last_name: tourist_split[0], first_name: tourist_split[1], middle_name: tourist_split[2] }
          end
          tourists
        end

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
            data_row[key].delete(:type)
            data_row[key][:value] = field unless field.blank?
          end
        #  puts data_row.to_s
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
            return { cant_be_nil: field }  if row[field[0]][:value].nil? && !row[field[0]][:may_nil]
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

        def tourist_check(t_names, company)
          tourist = Tourist.where(:company_id => company.id)
            .where("last_name = ? and first_name = ? and middle_name = ?", t_names[:last_name], t_names[:first_name], t_names[:middle_name])
            .first
          if tourist
            return tourist
          else
            puts "Tourist #{t_names[:last_name]} #{t_names[:first_name]} #{t_names[:middle_name]} not found"
            return false
          end
        end

        def operator_check(row, company)
          if row[:operator][:value]
            operator = Operator.where(:company_id => company.id)
              .where("(company_id = ? or common = true ) and name = ?", company.id, row[:operator][:value])
              .first
          end
          operator =
            unless operator
              Operator.new do |o|
                o.name = row[:operator][:value]
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

        def create_claim_params(row, company)
          {
            :num => row[:num],
            :reservation_date => row[:reservation_date],
            :check_date => row[:check_date],
            :tourist_stat => row[:promotion],
            :arrival_date => row[:arrival_date],
            :departure_date => row[:departure_date],
            :visa => row[:visa],
            :visa_check => row[:visa_check],
            :primary_currency_price => row[:primary_currency_price],
            :operator_confirmation_flag=>"0",
            :closed=>"0",
            :operator_confirmation => row[:operator_confirmation],
            :operator_price => row[:operator_price],
            :operator_maturity => row[:operator_maturity],
            :operator_paid => row[:operator_paid],
            :docs_note => row[:docs_note],
            :tourist_advance => row[:tourist_advance],
            :documents_status => row[:documents_status],
            :country => { "name" => row[:country] },
            :operator => row[:operator].nil? ? nil : row[:operator]['name'],
            :operator_id => row[:operator].nil? ? nil : row[:operator]['id'],
            :tour_price_currency => "rur",
            :operator_price_currency => "rur"
          }
        end
      end
    end
  end
end