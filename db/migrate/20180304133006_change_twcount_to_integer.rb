class ChangeTwcountToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :articles, :tw_count, 'integer using tw_count::integer'
  end
end
