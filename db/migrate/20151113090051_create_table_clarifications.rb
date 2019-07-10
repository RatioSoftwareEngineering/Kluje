class CreateTableClarifications < ActiveRecord::Migration
  def change
    create_table :table_clarifications do |t|
      t.belongs_to :job, null: false
      t.belongs_to :contractor, null: false

      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
