class ArticlesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    if params[:tag]
      if params[:sort]
        @articles = Article.tagged_with(params[:tag]).order(sort_column + " " + sort_direction)
      else
        @articles = Article.tagged_with(params[:tag])
      end
    else params[:sort]
      @articles = Article.order(sort_column + " " + sort_direction)
    end
  end

  def top
    @articles = Article.where(publication_date: DateTime.now-1..DateTime.now).order(total_views: :desc).first(10)
    @top_cointelegraph = Article.where(publication_date:DateTime.now-1..DateTime.now).where(source:"Coin Telegraph").order(total_views: :desc).first(5)
    @top_coindesk = Article.where(publication_date:DateTime.now-1..DateTime.now).where(source:"CoinDesk").order(tw_count: :desc).first(5)
    @top_bitcoin = Article.where(publication_date:DateTime.now-1..DateTime.now).where(source:"Bitcoin.com").order(total_views: :desc).first(5)
  end

  def top_tags
    @top_tags = Article.tag_counts.order(taggings_count: :desc).first(100)
  end

  private

  def sort_column
    %w[source title author total_views tw_count publication_date].include?(params[:sort]) ? params[:sort] : "publication_date"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
