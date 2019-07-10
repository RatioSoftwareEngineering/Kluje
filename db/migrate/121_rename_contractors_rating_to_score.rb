class RenameContractorsRatingToScore < ActiveRecord::Migration
  def change
    rename_column :contractors, :rating, :score
    Contractor.all.each(&:update_score)
  end
end
