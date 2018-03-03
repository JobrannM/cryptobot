require 'open-uri'
require 'nokogiri'

class BitcoinScraperService
  attr_accessor :@urls_to_scrape, :@bitcoin_articles, :@article_tags

  def initialize
    @urls_to_scrape = []
    @bitcoin_articles = []
    @article_tags = []
  end

  def perform
    url = 'https://news.bitcoin.com/'
    html_doc = Nokogiri::HTML(open(url).read)

    html_doc.search('.td-big-grid-post .entry-title a').each do |element|
      @urls_to_scrape << element.attribute('href').value
    end

    html_doc.search('.td_module_mx16 .td-module-title a').each do |element|
      @urls_to_scrape << element.attribute('href').value
    end

    html_doc.search('.td_module_mx1 .entry-title a').each do |element|
      @urls_to_scrape << element.attribute('href').value
    end

    @urls_to_scrape.each do |url|
      article_tags = []
      html_doc = Nokogiri::HTML(open(url).read)
      html_doc.search('.td-btc-posts-title .entry-title').each do |element|
        @title = element.text.strip
      end
      html_doc.search('.btc-post-meta .td-post-author-name a').each do |element|
        @author = element.text.strip
      end
      html_doc.search('.btc-post-meta .td-post-views span').each do |element|
        @total_views = element.text.strip
      end
      html_doc.search('.post .td-post-source-tags a, .post .td-post-source-tags span').each do |element|
        @article_tags << element.text.strip
      end
      html_doc.search("meta[itemprop='datePublished']").each do |element|
        @publication_date = element.attribute('content').value
      end
      article = {
      source: "Bitcoin.com",
      title: @title,
      author: @author,
      publication_date: @publication_date,
      url: url,
      tags: @article_tags,
      total_views: @total_views
      }
      @bitcoin_articles << article
    end
  end

end
