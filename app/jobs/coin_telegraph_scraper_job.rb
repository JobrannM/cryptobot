class CoinTelegraphScraperJob < ApplicationJob
  queue_as :default

  def perform
    scraper = CTScraperService.new
    scraper.perform
  end
end
