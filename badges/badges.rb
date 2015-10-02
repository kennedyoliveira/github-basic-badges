require 'net/http'
require 'json'
require './badges/badge'
require './badges/http_utils'
require './badges/badge_utils'

module Badges

  # Exception while interacting with badges
  class BadgeException < Exception
  end

end