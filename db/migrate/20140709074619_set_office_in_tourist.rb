class SetOfficeInTourist < ActiveRecord::Migration
  def up
    ThinkingSphinx.deltas_enabled = false

    Tourist.where('office_id is NULL').find_each do |tourist|
      if tourist.user && tourist.user.office
        tourist.update_column(:office_id, tourist.user.office.id)
      end
    end
  end

  def down
  end
end
