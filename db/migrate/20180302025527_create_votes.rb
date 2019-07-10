class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :account, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true
    end
  end
end
