require 'open-uri'
require 'nokogiri'

class CoindeskScraperService
  attr_accessor :@urls_to_scrape, :@coindesk_articles, :@article_tags

  def initialize
    @urls_to_scrape = []
    @coindesk_articles = []
    @article_tags = []
  end

  def perform
    url = "https://cointelegraph.com/category/latest"
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    #scrape all URLs from shown articles
    html_doc.search('.post .image a').each do |element|
      url = element.attribute('href').value
      @urls_to_scrape << url
    end

    @urls_to_scrape.each do |url|
      html_file = open(url).read
      html_doc = Nokogiri::HTML(html_file)
      html_doc.search('.post-area').each do |element|
        @title = element.attribute('data-title').value,
        @article_url = element.attribute('data-url').value,
        @fb_count = element.attribute('data-fb-count').value
        @red_count = element.attribute('data-reddit-count').value
        @tw_count = element.attribute('data-tw-count').value
      end
      html_doc.search('.name a').each do |element|
        @author = element.text.strip
      end
      html_doc.search('.date').each do |element|
        @publication_date = element.attribute('datetime').value
      end
      html_doc.search('.tags a').each do |element|
        tag = element.text.strip
        @article_tags << tag
      end
      html_doc.search('.total-views .total-qty').each do |element|
        @total_views = element.text.strip
      end
      article = {
        source: "Coin Telegraph",
        title: @title,
        author: @author,
        publication_date: @publication_date,
        url: @article_url,
        tags: @article_tags,
        fb_count: @fb_count,
        red_count: @red_count,
        tw_count: @tw_count,
        total_views: @total_views
      }
      @coindesk_articles << article
    end
  end

end
