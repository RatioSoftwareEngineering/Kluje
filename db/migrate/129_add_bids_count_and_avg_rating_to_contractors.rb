class AddBidsCountAndAvgRatingToContractors < ActiveRecord::Migration
  def self.up
    add_column :contractors, :bids_count, :integer, default: 0
    add_column :contractors, :average_rating, :float, default: 0

    Contractor.find_each do |contractor|
      contractor.update_average_rating
      Contractor.reset_counters(contractor.id, :bids)
    end
  end

  def self.down
    remove_column :contractors, :bids_count
    remove_column :contractors, :average_rating
  end
end
