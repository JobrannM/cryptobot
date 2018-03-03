class ArticlesController < ApplicationController

  def index
    @articles = Article.where(publication_date: )
  end
end
