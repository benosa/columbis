module Import
  module Tables
    class ClientSimpleTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :full_name     => {:type => 'String', :may_nil => false, :value => nil},
          :phone_number  => {:type => 'String', :may_nil => true, :value => nil},
          :email         => {:type => 'String', :may_nil => true, :value => nil},
          :wishes        => {:type => 'String', :may_nil => true, :value => nil},
        }

    #  class << self
        def self.columns_count
          4
        end

        def self.sheet_number
          0
        end

        def import(row, company, import_new, line)
          puts "Start import Tourist"
          puts row.to_s
          boss = User.where(company_id: company.id, role: 'boss').first

          data_row = prepare_data(row, company)

          params = create_client_params(data_row, company)
          if (!check_exist(params, company))
            tourist = Tourist.new(params)
            tourist.company = company
            tourist.user = boss if boss
            info_params = { model_class: 'Tourist', file_line: line, success:false }
            if tourist.save
              info_params[:model_id] = tourist.id
              info_params[:success] = true
              puts "Tourist was importing"
              true
            else
              puts tourist.errors.inspect
              info_params[:data] = tourist.errors.messages.to_yaml
              puts "Tourist not save"
              false
            end
            DefaultTable.save_import_item(info_params, import_new)
          else
            puts "Tourist exist"
          end
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
          tourist = Tourist.where(last_name: params[:last_name], first_name: params[:first_name], middle_name: params[:middle_name], company_id: company.id, potential: true).first
          tourist
        end

        def create_client_params(row, company)
          {
            :full_name => row[:full_name][:value],
            :phone_number => row[:phone_number][:value],
            :email => row[:email][:value],
            :wishes => row[:wishes][:value],
            :potential => true
          }
        end
    #  end
    end
  end
end