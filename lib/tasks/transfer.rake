# -*- encoding : utf-8 -*-
namespace :transfer do
  desc "Create accaunt for humans, who are working on the project"
  task :create_specific_users => :environment do
    company = Company.find(8) # Мистраль
    office = Office.find(7) # Корстон
    password = '123,ewq'
    user_params = [
      { email: 's_pash@mail.ru', login: 's_pash', last_name: 'Савинский', first_name: 'Павел' },
      { email: 'vampir.666.87@gmail.com', login: 'seobomj', last_name: 'Сео', first_name: 'Бомж' },
      { email: 'brutalmarketing@gmail.com', login: 'brutalmarketing', last_name: 'Коршунов', first_name: 'Сергей' }
    ].each do |params|
      user = User.new(params.merge({ office_id: office.id, password: password, password_confirmation: password }))
      user.company = company
      user.role = 'admin'
    end
  end
end