class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.belongs_to :account
      t.string :name
      t.string :email
      t.text :question
    end
  end

  def self.down
    drop_table :questions
  end
end
