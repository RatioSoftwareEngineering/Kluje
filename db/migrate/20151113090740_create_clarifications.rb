class CreateClarifications < ActiveRecord::Migration
  def change
    create_table :clarifications do |t|
      t.belongs_to :job, null: false
      t.belongs_to :contractor, null: false

      t.string :question
      t.string :answer

      t.timestamps null: false
    end
  end
end
