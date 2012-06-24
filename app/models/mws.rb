require "openssl"
require "base64"
require 'cgi'
require 'httparty'
require 'csv'

class Mws
  attr_accessor :response, :results
  
  def initialize
    @SELLER_ID = "A3RJNXUWUB0XCQ"
    @KEY = "AKIAI3WLFYBOCRAA6QMQ"
    @SECRET = "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"
  end
  
  # def GetSellerListings(report_id)
  #
  # NOTE AB: methods should be snake case
  # Added a default report_id for testing/laziness ;)
  # Should be removed when we're finished hacking around
  def get_seller_listings(report_id='6736979923')
    timestamp = CGI.escape(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    request   = request_params("GetReport",report_id, timestamp)
    signature = encode(sign(request))

    signed_params = request_params("GetReport",report_id, timestamp, signature) #"6736979923"
    url = generate_url(signed_params)

    @response = execute(url)
    
    # NOTE AB: This is causing Errno::ENAMETOOLONG: File name too long
    # removing for now.
    #
    # CSV.foreach(response.body,{:row_sep => "\t"}).each do |field|
    #   puts field.split(/\t/)
    # end
  end

  # NOTE AB: Parsed manually, because, why not ;)
  def parse_response
    data    = @response.split(/\t/) # split into an array on tabs /\t/
    headers = data.slice!(0..25) # capture headers, remove from data
    @results = [] # initialize results for availability in loop

    # Iterate over data each while grouping by 25 (number of headers)
    data.each_slice(25) do |row|
      parsed_row = {}
      # Since the 'row' is an array of 25 and we have the headers... let's 
      # turn it into a hash for easy of reteival
      row.each_with_index do |col, index|
        parsed_row[headers[index]] = col
      end
      # Add to results that will persist beyone the scope of the loop.
      @results << parsed_row
    end

    @results # We could omit this but I like the explict return in this case.
  end
 
  private
  
    def request_params(action, report_id, timestamp, signature=nil)  
      request_params = {
        "Action" => action,
        "SignatureVersion" => 2,
        "Timestamp" => timestamp,
        "Version" => "2009-01-01",
        "Signature" => signature,
        "SignatureMethod" => "HmacSHA256",
        "ReportId" => report_id,
        "Merchant" => @SELLER_ID,
        "AWSAccessKeyId" => @KEY
      }
      request_params.delete("Signature") unless signature
      Hash[request_params.sort].map{|k,v| "#{k}=#{v}"}.join('&')
    end

    def string_to_sign(request_params)
      "POST" + "\n" + "mws.amazonservices.com" + "\n" + "/" + "\n" + request_params
    end

    def sign(string)
      digest = OpenSSL::Digest::Digest.new("sha256")
      hmac = OpenSSL::HMAC.digest(digest, @SECRET, string_to_sign(string))
    end

    def encode(string)
      CGI.escape(Base64.encode64(string).strip)
    end

    def generate_url(signed_params)
      "https://mws.amazonservices.com/?" + signed_params
    end

    def execute(url)
      # `curl -X POST "#{url}"`
      HTTParty.post(url)
    end  
end
