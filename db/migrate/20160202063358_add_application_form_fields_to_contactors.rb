class AddApplicationFormFieldsToContactors < ActiveRecord::Migration
  def change
    add_column :contractors, :company_red, :string
    add_column :contractors, :company_rn, :string
    add_column :contractors, :company_rd, :string

    add_column :contractors, :date_incor, :datetime

    add_column :contractors, :relevant_activitie, :string
    add_column :contractors, :association_name, :string
    add_column :contractors, :membership_no, :string

    add_column :contractors, :company_brochure, :string
    add_column :contractors, :project, :string
    add_column :contractors, :financial_report, :string
    add_column :contractors, :bank_statement, :string

    add_column :contractors, :legal, :boolean
    add_column :contractors, :legal_text, :string
  end
end
