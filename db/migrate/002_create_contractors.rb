class CreateContractors < ActiveRecord::Migration
  def change
    create_table :contractors do |t|
      t.string      :company_name, null: false
      t.string      :company_street_no
      t.string      :company_street_name
      t.string      :company_unit_no
      t.string      :company_building_name
      t.string      :company_postal_code
      t.string      :company_name_slug, null: false
      t.string      :company_logo

      t.integer     :plan_id

      t.string      :nric_no
      t.string      :uen_number
      t.string      :bca_license
      t.string      :hdb_license

      t.string      :billing_name
      t.text        :billing_address
      t.string      :billing_postal_code
      t.string      :billing_phone_no

      t.boolean     :mobile_alerts, default: true, null: false
      t.boolean     :email_alerts, default: true, null: false
      t.decimal     :rating, precision: 5, scale: 2

      t.datetime    :deleted_at
      t.timestamps
    end
  end
end
