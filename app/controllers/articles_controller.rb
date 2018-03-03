class ArticlesController < ApplicationController

  def index
    @articles = Article.where(publication_date: Date.today)
    @top_cointelegraph = Article.where(publication_date:Date.today).where(source:"Coin Telegraph").order(total_views: :desc).first(5)
    @top_bitcoin = Article.where(publication_date:Date.today).where(source:"Bitcoin.com").order(total_views: :desc).first(5)
  end

end
