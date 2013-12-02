collection @tourists, :root => false, :object_root => false
attributes :id, :passport_series, :passport_number, :phone_number, :email
node(:value) { |t| t.full_name }
node(:label) { |t| t.full_name }
node(:date_of_birth) { |t| t.date_of_birth.try(:strftime, '%d.%m.%Y') }
node(:passport_valid_until) { |t| t.passport_valid_until.try(:strftime, '%d.%m.%Y') }
node(:address) { |t| t.address.try(:joint_address) }
node(:sex) { |t| t.sex }
# node(:id) { |t| t['id'] }
# node(:label) { |t| t['full_name'] "#{last_name} #{first_name} #{middle_name if middle_name}".strip }
# node(:value) { |t| t['full_name'] }
# node(:passport_series) { |t| t['passport_series'] }
# node(:passport_number) { |t| t['passport_number'] }
# node(:phone_number) { |t| t['phone_number'] }
# node(:date_of_birth) { |t| t['date_of_birth'].try(:strftime, '%d.%m.%Y') }
# node(:passport_valid_until) { |t| t['passport_valid_until'].try(:strftime, '%d.%m.%Y') }
# node(:address) { |t| t['joint_address'] }