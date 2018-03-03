require 'open-uri'
require 'nokogiri'


class ArticlesScraperService
  attr_accessor :urls_to_scrape, :article_tags, :bitcoin_articles, :coindesk_articles, :cointelegraph_articles

  def initialize
  end

  def perform
    bitcoin
    cointelegraph
  #   coindesk
  end

  private

  def bitcoin
    urls_to_scrape = []
    bitcoin_articles = []
    html_doc = Nokogiri::HTML(open('https://news.bitcoin.com/').read)

    html_doc.search('.td-big-grid-post .entry-title a, .td_module_mx16 .td-module-title a, .td_module_mx1 .entry-title a').each do |element|
      urls_to_scrape << element.attribute('href').value
    end

    urls_to_scrape.each do |url|
      article_tags = []
      html_doc = Nokogiri::HTML(open(url).read)
      html_doc.search('.td-btc-posts-title .entry-title').each do |element|
        @title = element.text.strip
      end
      html_doc.search('.btc-post-meta .td-post-author-name a').each do |element|
        @author = element.text.strip
      end
      html_doc.search('.btc-post-meta .td-post-views span').each do |element|
        @total_views = element.text.strip.to_i
      end
      html_doc.search('.post .td-post-source-tags a').each do |element|
        article_tags << element.text.strip
      end
      html_doc.search("meta[itemprop='datePublished']").each do |element|
        @publication_date = Date.parse(element.attribute('content').value).to_date
      end
      article = Article.new(
      source: "Bitcoin.com",
      title: @title,
      author: @author,
      publication_date: @publication_date,
      url: url,
      tags: article_tags,
      total_views: @total_views
      )
      article.save!
    end
  end

  def cointelegraph
    urls_to_scrape = []
    cointelegraph_articles = []
    html_doc = Nokogiri::HTML(open("https://cointelegraph.com/").read)
    #scrape all URLs from shown articles
    html_doc.search('.posts .post .image a').each do |element|
      urls_to_scrape << element.attribute('href').value
    end

    urls_to_scrape.each do |url|
      article_tags = []
      html_doc = Nokogiri::HTML(open(url).read)
      html_doc.search('.post-area').each do |element|
        @title = element.attribute('data-title').value
        @fb_count = element.attribute('data-fb-count').value
        @red_count = element.attribute('data-reddit-count').value
        @tw_count = element.attribute('data-tw-count').value
      end
      html_doc.search('.name a').each do |element|
        @author = element.text.strip
      end
      html_doc.search('.date').each do |element|
        @publication_date = Date.parse(element.attribute('datetime').value).to_date
      end
      html_doc.search('.tags a').each do |element|
        article_tags << element.text.strip
      end
      html_doc.search('.total-views .total-qty').each do |element|
        @total_views = element.text.strip.to_i
      end
      article = Article.new(
        source: "Coin Telegraph",
        title: @title,
        author: @author,
        publication_date: @publication_date,
        url: url,
        tags: article_tags,
        fb_count: @fb_count,
        red_count: @red_count,
        tw_count: @tw_count,
        total_views: @total_views
      )
      article.save!
    end
  end

  def coindesk
    urls_to_scrape = []
    coindesk_articles = []
    html_doc = Nokogiri::HTML(open("https://www.coindesk.com").read)

    html_doc.search('.article-featured a').each do |element|
      urls_to_scrape << element.attribute('href').value
    end

    html_doc.search('.picture a').each do |element|
      urls_to_scrape << element.attribute('href').value
    end


    urls_to_scrape.each do |url|
      article_tags = []
      html_doc = Nokogiri::HTML(open(url).read)
      html_doc.search('.article-top-title').each do |element|
        @title = element.text.strip
      end
      html_doc.search('.article-container-lab-name').each do |element|
        @author = element.text.strip
      end
      html_doc.search('.article-container-left-timestamp').each do |element|
        @publication_date = element.text.strip
      end
      html_doc.search('.single-tags a').each do |element|
        article_tags << element.text.strip
      end
      article = Article.new(
        source: "CoinDesk",
        title: @title,
        author: @author,
        publication_date: @publication_date,
        url: url,
        tags: article_tags,
      )
      article.save!
    end
  end

end
