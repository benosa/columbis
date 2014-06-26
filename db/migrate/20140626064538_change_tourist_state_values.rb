class ChangeTouristStateValues < ActiveRecord::Migration
  def up
    Tourist.where(:state => 'important').update_all(:state => 'selection')
  end

  def down
  end
end
