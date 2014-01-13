module Import
  module Tables
    module OperatorTable
      extend Tables::DefaultTable

      FORMAT =
        {
          :claim_num               => {:type => 'Int', :may_nil => false, :value => nil},
          :date_in                 => {:type => 'String', :may_nil => false, :value => nil},
          :currency                => {:type => 'Float', :may_nil => true, :value => nil},
          :amount                  => {:type => 'Int', :may_nil => true, :value => nil},
          :description             => {:type => 'String', :may_nil => true, :value => nil},
          :form                    => {:type => 'String', :may_nil => true, :value => nil},
          :amount_prim             => {:type => 'Int', :may_nil => true, :value => nil},
          :approved                => {:type => 'String', :may_nil => true, :value => nil},
          :course                  => {:type => 'String', :may_nil => true, :value => nil},
          :reversed_course          => {:type => 'String', :may_nil => true, :value => nil}
        }

      class << self
        def columns_count
          10
        end

        def sheet_number
          4
        end

        def import(row, company)
          puts "Start import Operator"
          puts row.to_s

          data_row = prepare_data(row, company)

          params = create_operator_params(data_row, company)
          if (!check_exist(params, company))
            operator = Operator.new(params)
            operator.company = company
            if operator.save
              if data_row[:address][:value]
                operator.create_address(company_id: company.id, joint_address: data_row[:address][:value] )
              end
              puts "Operator was importing"
              true
            else
              puts operator.errors.inspect
              puts "Operator not save"
              false
            end
          else
            puts "Operator exist"
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

       # def check_exist(params, company)
       #   operator = Operator.where(name: params[:name], company_id: company.id).first
       #   operator
       # end

        def create_payment_params(row, company)
          {
            :claim_id                => row[:claim_num][:value],
            :date_in                 => row[:date_in][:value],
            :currency                => row[:currency][:value],
            :amount                  => row[:amount][:value],
            :description             => row[:description][:value],
            :form                    => row[:form][:value],
            :amount_prim             => row[:amount_prim][:value]},
            :approved                => row[:approved][:value],
            :course                  => row[:course][:value],
            :reversed_course         => row[:reversed_course][:value]
          }
        end
      end
    end
  end
end