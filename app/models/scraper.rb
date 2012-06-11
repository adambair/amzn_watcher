require 'open-uri'

class Scraper
  attr_accessor :doc, :results
  
  def initialize(asin)
    base_url = "http://www.amazon.com/gp/offer-listing/"
    @asin = asin
    @url = base_url + asin
  end
  
  def fetch
    @doc = Nokogiri::HTML(open(@url))
  end
  
  def parse
    # get an array of results
    @results = @doc.css('.result')
    
    @results.each do |result|
      seller_id = extract_seller_id(result)
      
      merchant = Merchant.find_by_seller_id(seller_id)
      
      if !merchant
        # If merchant doesn't already exist, create it.
        merchant = Merchant.create(name:extract_merchant_name(result), rating:extract_rating(result), seller_id:seller_id)
      end
      
      # create product instance
      product = Product.create(asin:@asin,condition:extract_condition(result),price:extract_price(result),shipping_price:extract_shipping_price(result))
      merchant.products << product

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
  
    def extract_merchant_name(result)
      if result.css('.seller').first
        # text
        result.css('.seller a b').text
      else
        # logo alt tag
        result.css('.sellerInformation img').first['alt']
      end
    end
    
    def extract_seller_id(result)
      result.css('.rating a').first['href'].split('&seller=')[1]
    end

    def extract_condition(result)
      result.css('.condition').text.split(/\n/)[0]
    end
    
    def extract_rating(result)
      result.css('.rating b').text.split('%')[0].to_i
    end
    
end