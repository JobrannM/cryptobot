class Article < ApplicationRecord
  validates :source, :title, :author, :url, :publication_date, presence: :true
  validates :url, uniqueness: :true
  before_save :set_default
  acts_as_taggable

  def set_default
    self.tw_count = 0 if self.tw_count.nil?
    self.total_views = 0 if self.total_views.nil?
  end
end
