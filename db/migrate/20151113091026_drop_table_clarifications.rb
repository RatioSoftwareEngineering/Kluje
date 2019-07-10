class DropTableClarifications < ActiveRecord::Migration
  def up
    drop_table :table_clarifications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
