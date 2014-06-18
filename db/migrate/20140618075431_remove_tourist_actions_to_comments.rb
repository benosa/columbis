class RemoveTouristActionsToComments < ActiveRecord::Migration
  def up
    Tourist.where('length(actions) > 0').find_each do |tourist|
      comment = TouristComment.new(tourist_id: tourist.id, created_at: tourist.updated_at, body: tourist.actions)
      comment.user = tourist.user if tourist.user
      comment.save
    end
  end
end
