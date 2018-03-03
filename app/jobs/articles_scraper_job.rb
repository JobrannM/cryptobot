class ArticlesScraperJob < ApplicationJob
  queue_as :default

  def perform
    scraper
  end

  private

  def scraper
    articles_scraper = ArticlesScraperService.new
    articles_scraper.perform
  end

  # def article_generator(bitcoin_articles, coindesk_articles, cointelegraph_articles)

  # end
end
