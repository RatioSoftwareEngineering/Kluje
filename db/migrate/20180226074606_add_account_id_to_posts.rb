class AddAccountIdToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :account, index: true, foreign_key: true
  end
end
