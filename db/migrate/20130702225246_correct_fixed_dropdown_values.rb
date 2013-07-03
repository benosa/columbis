class CorrectFixedDropdownValues < ActiveRecord::Migration
  class DropdownValue < ActiveRecord::Base
  end

  def up
    # Remove all values for fixed lists
    DropdownValue.where(list: [:medical_insurance, :placement, :meals]).delete_all

    # New common values
    {
      :medical_insurance => %w(Да Нет),
      :placement => %w(SNGL SNGL+1CHD SNGL+2CHD DBL DBL+1CHD DBL+2CHD TRPL),
      :meals => (
        <<-EOS
          AI (питание + напитки местного производства)
          BB (завтрак)
          FB (завтрак + обед + ужин)
          HB (завтрак + ужин)
          RO (без питания)
          UAI (питание целый день + доп. бесплатный сервис))
        EOS
      ).split("\n").map{|val| val.strip}.select{|val| val.length > 0}
    }.each do |list, values|
      values.each do |value|
        DropdownValue.create list: list, value: value, common: true
      end
    end
  end

  def down
  end
end
