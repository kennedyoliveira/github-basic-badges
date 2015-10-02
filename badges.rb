require 'net/http'
require 'json'
require './badge.rb'
require './http_utils.rb'
require './badge_utils.rb'

module Badges

  # Exception while interacting with badges
  class BadgeException < Exception
  end

end