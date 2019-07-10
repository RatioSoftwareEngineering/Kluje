class CreateTableMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.belongs_to :job, null: false
      t.belongs_to :contractor, null: false

      t.date :date
      t.time :time
      t.string :place

      t.timestamps
    end
  end
end
