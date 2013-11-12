module Import
  module Tables
    module Claim
      extend Tables::DefaultTable

      FORMAT =
        {
          :column_1  => {:name => 'date',                   :type => 'date',   :may_nil => false, :value => Time.zone.now},
          :column_2  => {:name => 'promotion',              :type => 'string', :may_nil => false, :value => 'Другое'},
          :column_3  => {:name => 'user',                   :type => 'string', :may_nil => false, :value => nil},
          :column_4  => {:name => 'office',                 :type => 'string', :may_nil => false, :value => nil},
          :column_5  => {:name => 'full_name',              :type => 'string', :may_nil => false, :value => nil},
          :column_6  => {:name => 'telephone',              :type => 'string', :may_nil => false, :value => nil},
          :column_7  => {:name => 'pasport_number',         :type => 'string', :may_nil => false, :value => nil},
          :column_8  => {:name => 'pasport_series',         :type => 'string', :may_nil => false, :value => nil},
          :column_9  => {:name => 'email',                  :type => 'string', :may_nil => true,  :value => nil},
          :column_10 => {:name => 'date_of_birht',          :type => 'date',   :may_nil => false, :value => nil},
          :column_11 => {:name => 'pasport_valid_until',    :type => 'date',   :may_nil => false, :value => nil},
          :column_12 => {:name => 'arrival_date',           :type => 'date',   :may_nil => false, :value => nil},
          :column_13 => {:name => 'departure_date',         :type => 'date',   :may_nil => false, :value => nil},
          :column_14 => {:name => 'country',                :type => 'string', :may_nil => false, :value => nil},
          :column_15 => {:name => 'airport_back',           :type => 'string', :may_nil => false, :value => nil},
          :column_16 => {:name => 'visa',                   :type => 'string', :may_nil => false, :value => 'Виза не нужна'},
          :column_17 => {:name => 'visa_check',             :type => 'date',   :may_nil => true,  :value => nil},
          :column_18 => {:name => 'operator',               :type => 'string', :may_nil => false, :value => nil},
          :column_19 => {:name => 'operator_number',        :type => 'string', :may_nil => true,  :value => nil},
          :column_20 => {:name => 'operator_series',        :type => 'string', :may_nil => true,  :value => nil},
          :column_21 => {:name => 'operator_confirmation',  :type => 'string', :may_nil => true,  :value => nil},
          :column_22 => {:name => 'primary_currency_price', :type => 'float',  :may_nil => true,  :value => nil},
          :column_23 => {:name => 'operator_price',         :type => 'float',  :may_nil => true,  :value => nil},
          :column_24 => {:name => 'operator_maturity',      :type => 'date',   :may_nil => true,  :value => nil},
          :column_25 => {:name => 'operator_paided',        :type => 'float',  :may_nil => true,  :value => nil},
          :column_26 => {:name => 'paided',                 :type => 'float',  :may_nil => true,  :value => nil},
          :column_27 => {:name => 'documents_status',       :type => 'string', :may_nil => false, :value => 'Не готовы'},
          :column_28 => {:name => 'docs_note',              :type => 'text',   :may_nil => true,  :value => ''},
          :column_29 => {:name => 'check_date',             :type => 'date',   :may_nil => false, :value => Time.zone.now}
        }

      def self.columns_count
        FORMAT.length
      end

      def self.sheet_number
        1
      end

      def self.import(row)
        false
      end
    end
  end
end