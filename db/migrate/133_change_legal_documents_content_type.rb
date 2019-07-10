class ChangeLegalDocumentsContentType < ActiveRecord::Migration
  def self.up
    change_column :legal_documents, :content, :text, limit: 2_147_483_647
  end

  def self.down
    change_column :legal_documents, :content, :text
  end
end
