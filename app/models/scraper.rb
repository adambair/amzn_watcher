require 'open-uri'

class Scraper
  attr_accessor :doc, :results
  
  def initialize(asn)
    base_url = "http://www.amazon.com/gp/offer-listing/"
    @url = base_url + asn
  end
  
  def fetch
    @doc = Nokogiri::HTML(open(@url))
  end
  
  def scrape
    # get an array of results
    @results = @doc.css('.result')
    
    @results.collect do |result|
      [extract_price(result), extract_seller(result), extract_shipping_price(result), extract_condition(result),extract_rating(result) ]  
    end
    
  end

  private

    def extract_price(result)
      result.css('.price').text.split('$')[1].to_f
    end
  
    def extract_shipping_price(result)
      if result.css('.price_shipping')
        result.css('.price_shipping').text.split('$')[1].to_f
      else
        # prime eligible, so free shipping
        0.to_f
      end
    end
  
    def extract_seller(result)
      if result.css('.seller').first
        # text
        result.css('.seller a b').text
      else
        # logo
        result.css('.sellerInformation img').first['alt']
      end
    end

    def extract_condition(result)
      result.css('.condition').text.split(/\n/)[0]
    end
    
    def extract_rating(result)
      result.css('.rating b').text.split('%')[0].to_i
    end
    
end