class CreateLegalDocuments < ActiveRecord::Migration
  def change
    create_table :legal_documents do |t|
      t.string :title
      t.string :slug

      t.text :content

      t.string :seo_description
      t.string :seo_keywords

      t.string :language

      t.timestamps
    end
  end
end
