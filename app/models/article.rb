class Article < ApplicationRecord
  validates :source, :title, :author, :url, :publication_date, presence: :true
  validates :url, uniqueness: :true
  acts_as_taggable
end
