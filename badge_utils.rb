module Badges

  class BadgeUtils

    #
    # Generate the Badge in SVG format.
    #
    # @param [String] text Text to be displayed in the left said of a badge
    # @param [String] status Value to be displayed in the right side of a badge
    # @param [String] color Color that can be one of the following ... // TODO Document this crap
    # @param [Hash] params Extra params for customizing the badge // TODO Document this crap too
    # @return [String] SVG for the badge
    def self.build_badge(text, status, color, params=nil)
      uri = "https://img.shields.io/badge/#{URI.encode(text.to_s)}-#{URI.encode(status.to_s)}-#{color}.svg"

      resp = Badges::HttpUtils.get(uri, params)

      # If can't create the badge, raise a exception with the message
      raise Badges::BadgeException, resp.body unless resp.code == '200'

      resp.body
    end
  end
end
