#namespace :olo do
 # desc "seed dat demo company"
	task :ololo => :environment do
	 # Company.find_each do |company|
	  #	company.check_all_tariff_status
	 # end
	# Company.inactive.find_each do |company|
	 #  company.check_all_tariff_status
	# end
	# puts 'dfgdfg'
	Company.just_soon_become_inactive.mail_tariff_end_soon
	Company.just_become_inactive.mail_tariff_end
	#Company.inactive.mail_tariff_end
	end
#end