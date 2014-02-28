
#namespace :olo do
 # desc "seed dat demo company"
	task :ololo => :environment do
include Mistral::ApplicationHelperExtention
   tourists = []
   row = ["Асадуллина Ляйля, Блинкова Полина Сергеевна"]
   row[0].split(',').each do |tourist|
     tourist_split = tourist.split(' ')
     tourists << { last_name: tourist_split[0], first_name: tourist_split[1], middle_name: tourist_split[2] }
   end
	tourists[0..tourists.size].each do |t|
		puts t
    end

	#Company.inactive.mail_tariff_end
	end
#end