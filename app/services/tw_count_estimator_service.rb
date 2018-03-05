class TwCountEstimatorService
  attr_accessor :articles_sample

  def initialize
  end

  def perform
    bitcoin(calc_tw_trend)
    coindesk(calc_tw_trend)
  end

  private

  def calc_tw_trend
    sum = 0
    articles_sample =  Article.where(source:"Coin Telegraph").last(50)
    articles_sample.each do |article|
      sum += article.tw_count.to_f/article.total_views
    end
    average = sum / articles_sample.count
  end

  def bitcoin(ratio)
    Article.where(source:"Bitcoin.com").where(tw_count: 0).each do |article|
      count = article.total_views * ratio
      article.update_attribute("tw_count", count)
    end
  end

  def coindesk(ratio)
    Article.where(source:"CoinDesk").where(total_views: 0).each do |article|
      count = article.tw_count / ratio
      article.update_attribute("total_views", count)
    end
  end

end
