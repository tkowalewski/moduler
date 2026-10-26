class CreateModulerArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_articles do |t|
      t.string :path, null: false
      t.string :title, null: false
      t.string :description, null: false
      t.string :keywords, null: false
      t.text :content, null: false

      t.timestamps null: false
    end

    add_index :moduler_articles, :path, unique: true
  end
end
