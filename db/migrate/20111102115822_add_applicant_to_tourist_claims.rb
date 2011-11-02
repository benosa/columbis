class AddApplicantToTouristClaims < ActiveRecord::Migration
  def change
    add_column :tourist_claims, :applicant, :boolean, :default => false
  end
end
