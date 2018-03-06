require 'open-uri'
require 'nokogiri'
require 'pry'


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
    Article.where(source: source_to_match).where(created_at: DateTime.now-5..DateTime.now).each do |article|
      @articles_to_skip << article.url
    end
    @articles_to_skip
  end

  def quit_capybara(browser)
    browser.reset_session!
    browser.driver.quit
    browser = nil
  end

  def bitcoin
    find_articles_to_skip("Bitcoin.com")
    urls_to_scrape = []
    html_doc = Nokogiri::HTML(open('https://news.bitcoin.com/').read)

    html_doc.search('.entry-title a').each do |element|
      article_url = element.attribute('href').value
      if (article_url.start_with?('https://news.bitcoin.com/pr-') == false && @articles_to_skip.find_index(article_url).nil?)
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
        @publication_date = element.attribute('content').value.to_datetime
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
      article.save! if article.valid?
    end
  end

  def cointelegraph
    find_articles_to_skip("Coin Telegraph")
    urls_to_scrape = []
    html_doc = Nokogiri::HTML(open("https://cointelegraph.com/").read)
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
        @publication_date = element.attribute('datetime').value.to_datetime
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
      article.save! if article.valid?
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

    chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
    options = {}
    options[:args] = ['headless', 'disable-gpu', 'window-size=1280,1024']
    options[:binary] = chrome_bin if chrome_bin
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app,
       browser: :chrome,
       options: Selenium::WebDriver::Chrome::Options.new(options)
       )
    end
    Capybara.default_driver = :selenium
    browser = Capybara.current_session
    urls_to_scrape.each do |url|
      article_tags = []
      browser.visit url
      sleep(10)
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
      html_doc.search("meta[property='article:published_time']").each do |element|
        @publication_date = element.attribute('content').value.to_datetime
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
      article.save! if article.valid?
    end
    quit_capybara(browser)
  end



end
