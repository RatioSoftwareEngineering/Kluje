class AddCurrencyToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :currency, :string, default: 'sgd'
  end
end
