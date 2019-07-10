class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string      :name, null: false
      t.text        :description

      t.datetime    :deleted_at
      t.timestamps
    end
  end
end
