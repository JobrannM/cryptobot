class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :source
      t.string :title
      t.string :author
      t.date :publication_date
      t.string :url
      t.string :tags, array: true, default: []
      t.string :fb_count
      t.string :fb_share
      t.string :red_count
      t.string :red_share
      t.string :tw_count
      t.string :tw_share
      t.timestamps
    end
  end
end
