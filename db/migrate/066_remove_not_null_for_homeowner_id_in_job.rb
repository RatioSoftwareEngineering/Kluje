class RemoveNotNullForHomeownerIdInJob < ActiveRecord::Migration
  change_column :jobs, :homeowner_id, :integer, null: true
end
