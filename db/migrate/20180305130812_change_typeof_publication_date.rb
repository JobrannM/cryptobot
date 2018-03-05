class ChangeTypeofPublicationDate < ActiveRecord::Migration[5.1]
  def change
    change_column :articles, :publication_date, :datetime
  end
end
