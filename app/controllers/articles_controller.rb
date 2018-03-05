require 'date'
class ArticlesController < ApplicationController

  def index
    if params[:tag]
      if params[:sort]
        @articles = Article.tagged_with(params[:tag]).order(params[:sort] + " " + params[:direction])
      else
        @articles = Article.tagged_with(params[:tag])
      end
    elsif params[:sort]
      @articles = Article.order(params[:sort] + " " + params[:direction])
    else
      @articles = Article.order(publication_date: :desc)
    end
  end

  def top
    @articles = Article.where(publication_date: Date.today.all_day).order(total_views: :desc).first(10)
    @top_cointelegraph = Article.where(publication_date:Date.today.all_day).where(source:"Coin Telegraph").order(total_views: :desc).first(5)
    @top_coindesk = Article.where(publication_date:Date.today.all_day).where(source:"CoinDesk").order(tw_count: :desc).first(5)
    @top_bitcoin = Article.where(publication_date:Date.today.all_day).where(source:"Bitcoin.com").order(total_views: :desc).first(5)
  end

  def top_tags
    @top_tags = Article.tag_counts.order(taggings_count: :desc).first(100)
  end

end
