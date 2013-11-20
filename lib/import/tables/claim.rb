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
          :operator_paided        => {:type => 'Float',  :may_nil => true,  :value => nil},
          :paided                 => {:type => 'Float',  :may_nil => true,  :value => nil},
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
          # logger need
          data_row = check(row, company)
          if data_row
            claim = create_claim(data_row, company)
            if claim.save
              # logger need
            else
              # logger need
            end
          else
            # logger need
            false
          end
        end

        private

        def check(row, company)
          data_row = type_check(row)
          if data_row
            # logger need
            fields_check(data_row, company)
          else
            # logger need
            false
          end
        end

        def type_check(row)
          data_row = FORMAT.dup
          row.each_with_index do |field, i|
            key = data_row.keys[i]
            if field.nil? || field.class.to_s == data_row[key][:type]
              data_row[key][:value] = field unless field.nil?
            else
              # logger need
              return false
            end
          end
          data_row
        end

        def fields_check(row, company)
          row.each do |field|
            if private_instance_methods.include?("#{field[0]}_check") && !send("#{field[0]}_check", row, company)
              # logger need
              return false
            end
          end
        end

        def user_check(row, company)
          user = company.users.where(:login => row[:user]).first
          check_field(row[:user], user.try(:id))
        end

        def office_check(row, company)
          office = company.offices.where(:name => row[:office]).first
          office = company.offices.first if office.nil?
          check_field(row[:office], office.try(:id))
        end

        def full_name_check(row, company)
          tourist = Tourist.where(:company_id => company.id)
            .where("passport_series = '#{row[:passport_series][:value]}'")
            .where("passport_number = '#{row[:passport_number][:value]}'")
            .first unless (row[:passport_series][:value] == nil && row[:passport_number][:value] == nil)
          unless tourist
            tourist = Tourist.new do |t|
              t.full_name = row.delete(:full_name)
              t.passport_series = row.delete(:passport_series)
              t.passport_number = row.delete(:passport_number)
              t.passport_valid_until = row.delete(:passport_valid_until)
              t.date_of_birth = row.delete(:date_of_birth)
              t.email = row.delete(:email)
              t.phone_number = row.delete(:telephone)
            end
          end
          if tourist.id || tourist.valid?
            row.merge!({:tourist => tourist.attributes})
          else
            # logger need
            false
          end
        end

        def operator_check(row, company)
        end

        def airport_back_check(row, company)
          check_field(row[:airport_back], row[:airport_back][:value])
        end

        def visa_check(row, company)
          visa_statuses = {}
          Claim::VISA_STATUSES.each do |status|
            visa_statuses.merge!({ I18n.t(".claims.visa_statuses.#{status}") => status })
          end
          if visa_statuses.keys.include?(row[:visa][:value])
            row[:visa][:value] = visa_statuses[:value]
          else
            # logger need
            false
          end
        end

        def visa_check_ckeck(row, company)
          check_field(row[:visa_check], row[:visa_check][:value])
        end

        def check_field(field, value)
          if value.nil?
            false || field[:may_nil]
          else
            field[:value] = value
          end
        end

        def create_claim(row, company)
          claim = Claim.new do |c|
            # relations
            c.company_id = company
            c.user_id = row[:user]
            c.office_id = row["office"]
            # common
            c.reservation_date = row[:date]
            c.check_date = row[:check_date]
            c.tourist_stat = row[:promotion]
            c.arrival_date = row[:arrival_date]
            c.departure_date = row[:departure_date]
            c.country = row[:country]
            # tourist
            c.applicant_attributes = row[:tourist]
            # need add flights
            c.visa = row[:visa]
            c.visa_check = row[:visa_check]
            c.applicant_attributes = row[:tourist]
          end
        end
      end
    end
  end
end