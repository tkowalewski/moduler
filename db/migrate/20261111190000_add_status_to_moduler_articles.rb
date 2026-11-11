class AddStatusToModulerArticles < ActiveRecord::Migration[8.1]
  def change
    # Existing articles stay published; new articles are unpublished by default.
    add_column :moduler_articles, :status, :integer, default: 1, null: false
    change_column_default :moduler_articles, :status, from: 1, to: 0
    add_index :moduler_articles, :status
  end
end
