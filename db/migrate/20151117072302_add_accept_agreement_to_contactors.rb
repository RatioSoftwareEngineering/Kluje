class AddAcceptAgreementToContactors < ActiveRecord::Migration
  def change
    add_column :contractors, :accept_agreement, :boolean
  end
end
