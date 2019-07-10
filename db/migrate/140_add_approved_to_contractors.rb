class AddApprovedToContractors < ActiveRecord::Migration
  def self.up
    add_column :contractors, :approved, :boolean, default: false

    Contractor.joins(:credits).where('credits.id IS NOT NULL').update_all(approved: true)
  end

  def self.down
    remove_column :contractors, :approved
  end
end
