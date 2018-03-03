class ChangeTotalViewsToIntegers < ActiveRecord::Migration[5.1]
  def change
    change_column :articles, :total_views, 'integer using total_views::integer'
  end
end
