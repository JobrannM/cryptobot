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

end
