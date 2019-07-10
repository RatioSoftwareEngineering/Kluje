class AddVerificationRequestToContractor < ActiveRecord::Migration
  def change
    add_column :contractors, :verification_request, :boolean, default: false
  end
end
