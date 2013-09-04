class SetExistUsersConfirmedNow < ActiveRecord::Migration
  def up
  	User.find_each do |user|
  		user.update_column(:confirmed_at, Time.now)
  	end
  end

  def down
  	User.find_each do |user|
  		user.update_column(:confirmed_at, 'null')
  	end
  end
end
