class CreateContractorsSkills < ActiveRecord::Migration
  def self.up
    create_table :contractors_skills do |t|
      t.belongs_to 	:contractor
      t.belongs_to 	:skill

      t.timestamps
    end
  end

  def self.down
    drop_table :contractors_skills
  end
end
