class DropMeetings < ActiveRecord::Migration
  def up
    drop_table :meetings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
