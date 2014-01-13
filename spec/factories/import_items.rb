# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_item do
    import_info_id ""
    model_class ""
    model_id ""
    data ""
    file_line 1
  end
end
