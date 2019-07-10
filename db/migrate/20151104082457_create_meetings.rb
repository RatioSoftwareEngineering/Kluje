class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.belongs_to :job, null: false
      t.belongs_to :contractor, null: false

      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
