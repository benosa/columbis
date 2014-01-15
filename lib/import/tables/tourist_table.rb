module Import
  module Tables
    class TouristTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :last_name             => {:type => 'String', :may_nil => false, :value => nil},
          :first_name            => {:type => 'String', :may_nil => true, :value => nil},
          :middle_name           => {:type => 'String', :may_nil => true, :value => nil},
          :sex                   => {:type => 'String', :may_nil => true, :value => nil},
          :date_of_birth         => {:type => 'Date', :may_nil => true, :value => nil},
          :phone_number          => {:type => 'String', :may_nil => true, :value => nil},
          :email                 => {:type => 'String', :may_nil => true, :value => nil},
          :fio_latin             => {:type => 'String', :may_nil => true, :value => nil},
          :passport_series       => {:type => 'String', :may_nil => true, :value => nil},
          :passport_number       => {:type => 'String', :may_nil => true, :value => nil},
          :passport_valid_until  => {:type => 'Date', :may_nil => true, :value => nil},
          :passport_issued       => {:type => 'String', :may_nil => true, :value => nil},
          :address               => {:type => 'String', :may_nil => true, :value => nil}
        }

     # class << self
        def self.columns_count
          13
        end

        def self.sheet_number
          1
        end

        def import(row, company, import_new)
          puts "Start import Tourist"
          puts row.to_s

          data_row = prepare_data(row, company)

          params = create_tourist_params(data_row, company)
          if (!check_exist(params, company))
            tourist = Tourist.new(params)
            tourist.company = company
            tourist.sex = ClientTable.find_sex_state(data_row)
            info_params = { model_class: 'Tourist' }
            if tourist.save
              info_params[:model_id] = tourist.id
              if data_row[:address][:value]
                tourist.create_address(company_id: company.id, joint_address: data_row[:address][:value] )
              end
              puts "Tourist was importing"
              true
            else
              puts tourist.errors.inspect
              Rails.logger.debug "ololo555 #{tourist.errors.inspect}"
              puts "Tourist not save"
              false
            end
            DefaultTable.save_import_item(info_params, import_new)
          else
            puts "Tourist exist"
          end
        end

        private

        def prepare_data(row, company)
          data_row = Marshal.load(Marshal.dump(FORMAT))
          row.each_with_index do |field, i|
            key = data_row.keys[i]
            data_row[key][:value] = field unless field.blank?
          end
          data_row
        end

        def check_exist(params, company)
          tourist = Tourist.where(last_name: params[:last_name], first_name: params[:first_name], middle_name: params[:middle_name], company_id: company.id, potential: false).first
          tourist
        end

        def create_tourist_params(row, company)
          {
            :last_name => row[:last_name][:value],
            :first_name => row[:first_name][:value],
            :middle_name => row[:middle_name][:value],
            :date_of_birth => row[:date_of_birth][:value],
            :phone_number => row[:phone_number][:value],
            :email => row[:email][:value],
            :fio_latin => row[:fio_latin][:value],
            :passport_series => row[:passport_series][:value],
            :passport_number =>row[:passport_number][:value],
            :passport_valid_until => row[:passport_valid_until][:value],
            :passport_issued => row[:passport_issued][:value],
            :potential => false
          }
        end
    #  end
    end
  end
end