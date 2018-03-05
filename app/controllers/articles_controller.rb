require 'date'

class ArticlesController < ApplicationController

  def index
    if params[:tag]
      @articles = Article.tagged_with(params[:tag])
    elsif params[:sort]
      @articles = Article.order(params[:sort] + " " + params[:direction])
    else
      @articles = Article.all.order(publication_date: :desc)
    end
  end

  def top
    @articles = Article.where(publication_date: Date.today.all_day).order(total_views: :desc).first(10)
    @top_cointelegraph = Article.where(publication_date:Date.today.all_day).where(source:"Coin Telegraph").order(total_views: :desc).first(5)
    @top_coindesk = Article.where(publication_date:Date.today.all_day).where(source:"CoinDesk").order(tw_count: :desc).first(5)
    @top_bitcoin = Article.where(publication_date:Date.today.all_day).where(source:"Bitcoin.com").order(total_views: :desc).first(5)
  end

end
