class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.belongs_to  :contractor
      t.decimal     :amount, precision: 5, scale: 2, null: false
      t.string      :deposit_type

      t.timestamps
    end

    Contractor.all.each do |contractor|
      Credit.create(contractor_id: contractor.id, amount: Credit::SIGN_UP_BONUS, deposit_type: 'sign_up_bonus')
    end
  end
end
