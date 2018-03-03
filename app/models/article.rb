class Article < ApplicationRecord
  validates :source, :title, :author, :url, :publication_date, presence: :true
end
