module Badges

  # Utility method for Http interaction
  class HttpUtils

    #
    # Sends a request and returns a response
    #
    # @param [String] url Url for the request
    # @param [Hash] params Parameters for the get request
    # @return [Net::HTTPResponse] Response for the request
    def self.get(url, params=nil)
      uri = URI.parse(url)

      # Extra params for custom badges
      uri.query = URI.encode_www_form(params) unless params.nil? or params.empty?

      # Set up http client
      http = Net::HTTP.new(uri.host, uri.port)

      # Set up ssl mode
      # TODO Verify how to validate it
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      http.request(request)
    end
  end
end