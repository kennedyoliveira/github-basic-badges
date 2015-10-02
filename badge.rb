module Badges

  #
  # Basic colors for badges
  # Its possible to use any color with hex code
  BASIC_COLORS = { :blue => 'blue',
                   :red => 'red',
                   :lightgray => 'lightgray',
                   :green => 'green',
                   :bgreen => 'brightgreen',
                   :yellow => 'yellow',
                   :yellowgreen => 'yellowgreen',
                   :orange => 'orange',
                   :pink => 'ff69b4',
                   :lightblue => '00CCFF',
                   :purple => '9900ff' }

  # Represents a badge for Sinatra response
  class Badge

    attr_reader :text, :body, :color, :status

    # Creates a new Badge that can be used as response for with Sinatra
    # @param [String] text Text to be displayed in the left said of a badge
    # @param [String] status Value to be displayed in the right side of a badge
    # @param [String] color Color that can be one of the Badges::BASIC_COLORS or any hex color definition
    # @param [Hash] params Extra params for customizing the badge // TODO Document this
    def initialize(text, status, color, params = nil)
      @text = text
      @status = status
      @color = color

      @body = Badges::BadgeUtils.build_badge(text, status, color, params)
    end

    # Sinatra response object must responde to Each method
    def each
      yield @body
    end
  end

  def build_vendor_error_badge
    Badge.new('vendor', 'error', BASIC_COLORS[:lightgray])
  end
end

