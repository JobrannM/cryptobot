class AddTotalViewsToArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :total_views, :string
  end
end
