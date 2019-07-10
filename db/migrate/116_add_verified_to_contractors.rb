class AddVerifiedToContractors < ActiveRecord::Migration
  def change
    add_column :contractors, :verified, :boolean
  end
end
