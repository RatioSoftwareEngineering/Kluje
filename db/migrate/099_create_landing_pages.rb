class CreateLandingPages < ActiveRecord::Migration
  def change
    create_table :landing_pages do |t|
      t.string :title
      t.string :header
      t.string :description
      t.string :keywords
      t.string :slug
      t.text :content

      t.string :banner

      t.belongs_to :skill

      t.timestamps
    end
  end
end
