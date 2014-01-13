module Import
  module Tables
    module ClaimTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :num                             => {:type => 'Int',    :may_nil => false, :value => nil},
          :reservation_date                => {:type => 'Date',   :may_nil => false, :value => Time.zone.now},
          :tourist_stat                    => {:type => 'String', :may_nil => false, :value => 'Другое'},
          :office                          => {:type => 'String', :may_nil => false, :value => nil},
          :user                            => {:type => 'String', :may_nil => false, :value => nil},
          :tourist                         => {:type => 'String', :may_nil => false, :value => nil},
          :phone_number                    => {:type => 'String', :may_nil => false, :value => nil},
          :arrival_date                    => {:type => 'Date',   :may_nil => false, :value => nil},
          :departure_date                  => {:type => 'Date',   :may_nil => false, :value => nil},
          :country                         => {:type => 'String', :may_nil => false, :value => nil},
          :city                            => {:type => 'String', :may_nil => true,  :value => nil},
          :visa                            => {:type => 'String', :may_nil => true,  :value => 'Виза не нужна'},
          :visa_check                      => {:type => 'Date',   :may_nil => true,  :value => nil},
          :operator                        => {:type => 'String', :may_nil => false, :value => nil},
          :operator_confirmation           => {:type => 'String', :may_nil => true,  :value => nil},
          :primary_currency_price          => {:type => 'Float',  :may_nil => true,  :value => nil},
          :calculation                     => {:type => 'Float',  :may_nil => true,  :value => nil},
          :tourist_advance                 => {:type => 'Float',  :may_nil => false, :value => nil},
          :tourist_debt                    => {:type => 'Float',  :may_nil => false, :value => nil},
          :operator_price                  => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_maturity               => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_advance                => {:type => 'Float',  :may_nil => true,  :value => nil},
          :operator_debt                   => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_tourist_advance        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_operator_advance       => {:type => 'Float',  :may_nil => true,  :value => nil},
          :approved_operator_advance_prim  => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_acc                      => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_in_percent_acc           => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit                          => {:type => 'Float',  :may_nil => true,  :value => nil},
          :profit_in_percent               => {:type => 'Float',  :may_nil => true,  :value => nil},
          :bonus_percent                   => {:type => 'Float',  :may_nil => true,  :value => nil},
          :bonus                           => {:type => 'Float',  :may_nil => true,  :value => nil},
          :documents_status                => {:type => 'String', :may_nil => true,  :value => 'Не готовы'},
          :docs_note                       => {:type => 'String', :may_nil => true,  :value => ''},
          :check_date                      => {:type => 'Date',   :may_nil => false, :value => Time.zone.now},
          :early_reservation               => {:type => 'String', :may_nil => true,  :value => nil},
          :excluded_from_profit            => {:type => 'String', :may_nil => true,  :value => nil},
          :canceled                        => {:type => 'String', :may_nil => true,  :value => nil},
          :active                          => {:type => 'String', :may_nil => true,  :value => nil}
        }

      class << self
        def columns_count
          39
        end

        def sheet_number
          0
        end

        def import(row, company)
          puts "    Start import row."
          data_row = prepare_data(row, company)
          if data_row && !data_row[:cant_be_nil]
            params = create_claim_params(data_row, company)
           # puts params
            claim = Claim.new(params)

            claim.company = company
            claim.user = user_manual_check(data_row, company)
            claim.office = office_manual_check(data_row, company)
            claim.country = country_manual_check(data_row, company)
            claim.city = city_manual_check(data_row, company)
            tourists = parse_tourists(data_row)
            claim.applicant = tourist_manual_check(tourists[0], company) if tourists[0]
          #  puts claim.inspect
          #if claim.assign_reflections_and_save(params)
            info_params = { model_class: 'Claim' }
            if claim.save
              info_params[:model_id] = claim.id
              puts "    Claim was importing"
              true
            else
              puts claim.errors.inspect
              puts "    Claim not save"
              false
            end
            DefaultTable.save_import_item(info_params)
            #save_import_item(params)
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
          data_row = Marshal.load(Marshal.dump(FORMAT))
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
            # row[field[0]] = row[field[0]][:value]
          end
          row
        end

        def user_manual_check(row, company)
          user = company.users.where(:login => row[:user][:value]).first
          user
        end

        def office_manual_check(row, company)
          office = company.offices.where(:name => row[:office][:value]).first
          office = company.offices.first if office.nil?
          office
        end

        def tourist_manual_check(t_names, company)
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

        def operator_manual_check(row, company)
          if row[:operator][:value]
            operator = Operator.where(:company_id => company.id)
              .where("(company_id = ? or common = true ) and name = ?", company.id, row[:operator][:value])
              .first
          end
          unless operator
            operator = Operator.new(name: row[:operator][:value], common: false)
            operator.company = company
            operator.save
          end
          operator
        end

        def country_manual_check(row, company)
          if row[:country][:value]
            country = Country.where(:company_id => company.id)
              .where("(company_id = ? or common = true ) and name = ?", company.id, row[:country][:value])
              .first
          end
          unless country
            country = Country.new(name: row[:country][:value], common: false)
            country.company = company
            country.save
          end
          country
        end

        def city_manual_check(row, company)
          if row[:city][:value]
            city = City.where(:company_id => company.id)
              .where("(company_id = ? or common = true ) and name = ?", company.id, row[:city][:value])
              .first
          end
          unless city
            city = City.new(name: row[:city][:value], common: false)
            city.company = company
            city.save
          end
          city
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
         # puts row
          {
            :num => row[:num][:value].to_i,
            :reservation_date => row[:reservation_date][:value],
            :tourist_stat => row[:tourist_stat][:value],
            :arrival_date => row[:arrival_date][:value],
            :departure_date => row[:departure_date][:value],
            :visa => 'all_done',#row[:visa][:value],
            :visa_check => row[:visa_check][:value],
            :operator_confirmation => row[:operator_confirmation][:value],
            :primary_currency_price => row[:primary_currency_price][:value].to_f,
            :calculation => row[:calculation][:value],
            :tourist_advance => row[:tourist_advance][:value],
            :tourist_debt => row[:tourist_debt][:value],
            :operator_price => row[:operator_price][:value],
            :operator_maturity => row[:operator_maturity][:value],
            :operator_advance => row[:operator_advance][:value],
            :operator_debt => row[:operator_debt][:value],
            :approved_tourist_advance => row[:approved_tourist_advance][:value],
            :approved_operator_advance => row[:approved_operator_advance][:value],
            :approved_operator_advance_prim => row[:approved_operator_advance_prim][:value],
            :profit_acc => row[:profit_acc][:value],
            :profit_in_percent_acc => row[:profit_in_percent_acc][:value],
            :profit => row[:profit][:value],
            :profit_in_percent => row[:profit_in_percent][:value],
            :bonus_percent => row[:bonus_percent][:value],
            :bonus => row[:bonus][:value],
            :documents_status => row[:documents_status][:value],
            :docs_note => row[:docs_note][:value],
            :check_date => row[:check_date][:value],
            :early_reservation => row[:early_reservation][:value],
            :excluded_from_profit => row[:excluded_from_profit][:value],
            :canceled => row[:canceled][:value],
            :active => row[:active][:value],
          #  :operator_paid => row[:operator_paid][:value],
            :tour_price_currency => "rur",
            :operator_price_currency => "rur"
          }
        end
      end
    end
  end
end