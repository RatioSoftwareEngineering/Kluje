class DeleteCompanyBrochureToContractor < ActiveRecord::Migration
  def change
    remove_column :contractors, :company_brochure
    remove_column :contractors, :project
  end
end
