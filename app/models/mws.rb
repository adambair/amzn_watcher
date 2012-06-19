require "openssl"
require "base64"
require 'cgi'
require 'httparty'
require 'csv'

class Mws
  
  def initialize
    @SELLER_ID = "A3RJNXUWUB0XCQ"
    @KEY = "AKIAI3WLFYBOCRAA6QMQ"
    @SECRET = "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"
  end
  
  def GetSellerListings(report_id)
    timestamp = CGI.escape(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    request   = request_params("GetReport",report_id, timestamp)
    signature = encode(sign(request))

    signed_params = request_params("GetReport",report_id, timestamp, signature) #"6736979923"
    url = generate_url(signed_params)

    response = execute(url)
    
    CSV.foreach(response.body,{:row_sep => "\t"}).each do |field|
      #puts field.split(/\t/)
    end
        
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