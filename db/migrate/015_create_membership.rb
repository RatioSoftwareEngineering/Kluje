class CreateMembership < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to  :contractor, null: false
      t.integer     :plan_id, null: false
      t.string      :paypal_txn_id

      t.datetime    :expires_on, null: false
      t.datetime    :deleted_at
      t.timestamps
    end

    Contractor.all.each do |contractor|
      Membership.create(contractor_id: contractor.id, plan_id: 1, expires_on: contractor.created_at + 30.days)
    end
  end
end
