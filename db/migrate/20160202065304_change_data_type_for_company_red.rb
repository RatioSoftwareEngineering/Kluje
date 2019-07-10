class ChangeDataTypeForCompanyRed < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.change :company_red, :datetime
    end
  end

  def self.down
    change_table :contractors do |t|
      t.change :company_red, :string
    end
  end
end
