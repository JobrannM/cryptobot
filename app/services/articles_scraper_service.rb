require 'open-uri'
require 'nokogiri'
require 'watir'

class ArticlesScraperService
  attr_accessor :urls_to_scrape, :article_tags

  def initialize
  end

  def perform
    bitcoin
    cointelegraph
    coindesk
  end

  private


  def find_articles_to_skip(source_to_match)
    @articles_to_skip = []
    Article.where(source: source_to_match).where(publication_date: 7.days.ago..Date.today).each do |article|
      @articles_to_skip << article.url
    end
  end

  def bitcoin
    find_articles_to_skip("Bitcoin.com")
    urls_to_scrape = []
    html_doc = Nokogiri::HTML(open('https://news.bitcoin.com/').read)

    html_doc.search('.entry-title a').each do |element|
      article_url = element.attribute('href').value
      if @articles_to_skip.find_index(article_url).nil?
        urls_to_scrape << article_url
      end
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
      tag_list = article_tags.join(", ")
      html_doc.search("meta[itemprop='datePublished']").each do |element|
        @publication_date = Date.parse(element.attribute('content').value).to_date
      end
      article = Article.new(
      source: "Bitcoin.com",
      title: @title,
      author: @author,
      publication_date: @publication_date,
      url: url,
      tag_list: tag_list,
      total_views: @total_views
      )
      article.save!
    end
  end

  def cointelegraph
    find_articles_to_skip("Coin Telegraph")
    urls_to_scrape = []
    html_doc = Nokogiri::HTML(open("https://cointelegraph.com/").read)
    #scrape all URLs from shown articles
    html_doc.search('.posts .post .image a').each do |element|
      article_url = element.attribute('href').value
      if @articles_to_skip.find_index(article_url).nil?
        urls_to_scrape << article_url
      end
    end

    urls_to_scrape.each do |url|
      article_tags = []
      html_doc = Nokogiri::HTML(open(url).read)
      html_doc.search('.post-area').each do |element|
        @title = element.attribute('data-title').value
        @fb_count = element.attribute('data-fb-count').value
        @red_count = element.attribute('data-reddit-count').value
        @tw_count = element.attribute('data-tw-count').value.to_i
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
      tag_list = article_tags.join(", ")
      html_doc.search('.total-views .total-qty').each do |element|
        @total_views = element.text.strip.to_i
      end
      article = Article.new(
        source: "Coin Telegraph",
        title: @title,
        author: @author,
        publication_date: @publication_date,
        url: url,
        tag_list: tag_list,
        fb_count: @fb_count,
        red_count: @red_count,
        tw_count: @tw_count,
        total_views: @total_views
      )
      article.save!
    end
  end

  def coindesk
    find_articles_to_skip("CoinDesk")
    urls_to_scrape = []
    html_doc = Nokogiri::HTML(open("https://www.coindesk.com").read)
    html_doc.search('.article-featured a').each do |element|
      article_url = element.attribute('href').value
      if @articles_to_skip.find_index(article_url).nil?
        urls_to_scrape << article_url
      end
    end

    html_doc.search('.picture a').each do |element|
      article_url = element.attribute('href').value
      if @articles_to_skip.find_index(article_url).nil?
        urls_to_scrape << article_url
      end
    end

    browser = Watir::Browser.new :chrome, headless: true
    urls_to_scrape.each do |url|
      article_tags = []
      browser.goto(url)
      sleep(25)
      html_doc = Nokogiri::HTML(browser.html)
      html_doc.search('ul.share-bar li.twitter a .count').each do |element|
        @tw_count = element.text.strip.to_i
      end
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
      tag_list = article_tags.join(", ")
      article = Article.new(
        source: "CoinDesk",
        title: @title,
        author: @author,
        publication_date: @publication_date,
        url: url,
        tag_list: tag_list,
        tw_count: @tw_count
      )
      article.save!
    end
    browser.close
  end

end
