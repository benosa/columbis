module Import
  module Tables
    module ClientTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :created_at    => {:type => 'Date', :may_nil => false, :value => nil},
          :manager       => {:type => 'String', :may_nil => true, :value => nil},
          :full_name     => {:type => 'String', :may_nil => false, :value => nil},
          :sex           => {:type => 'String', :may_nil => true, :value => nil},
          :phone_number  => {:type => 'String', :may_nil => true, :value => nil},
          :email         => {:type => 'String', :may_nil => true, :value => nil},
          :wishes        => {:type => 'String', :may_nil => true, :value => nil},
          :actions       => {:type => 'String', :may_nil => true, :value => nil},
          :state         => {:type => 'String', :may_nil => true, :value => nil}
        }

      class << self
        def columns_count
          8
        end

        def sheet_number
          2
        end

        def import(row, company)
          puts "Start import Tourist"
          puts row.to_s

          data_row = prepare_data(row, company)

          params = create_client_params(data_row, company)
         # if (!check_exist(params, company))
            tourist = Tourist.new(params)
            tourist.company = company
            tourist.user = find_manager(data_row)
            tourist.state = find_state(data_row)
            if tourist.save
              puts "Tourist was importing"
              true
            else
              puts tourist.errors.inspect
              puts "Tourist not save"
              false
            end
         # else
         #   puts "Tourist exist"
         # end
        end

        private

        def find_manager(data_row)
          user = User.where(login: data_row[:manager][:value]).first
          puts user
          puts data_row[:manager][:value]
          user
        end

        def find_state(data_row)
          'important' if data_row[:state][:value] == 'Активно звонить!'
          'reserved' if data_row[:state][:value] == 'Забронирован'
          'refused' if data_row[:state][:value] == 'Отказался'
        end

        def prepare_data(row, company)
          data_row = Marshal.load(Marshal.dump(FORMAT))
          row.each_with_index do |field, i|
            key = data_row.keys[i]
            data_row[key][:value] = field unless field.blank?
          end
          data_row
        end

        def check_exist(params, company)
          tourist = Tourist.where(full_name: params[:full_name], company_id: company.id).first
          tourist
        end

        def create_client_params(row, company)
          {
            :full_name => row[:full_name][:value],
            :sex => row[:sex][:value],
            :phone_number => row[:phone_number][:value],
            :email => row[:email][:value],
            :wishes => row[:wishes][:value],
            :actions => row[:actions][:value],
            :potential => true
          }
        end
      end
    end
  end
end