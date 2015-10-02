require 'sinatra'
require 'net/http'

get '/' do
  subject = 'testing'
  status = 'OK'
  color = 'brightgreen'

  uri = URI.parse("https://img.shields.io/badge/#{subject}-#{status}-#{color}.svg")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  resp = http.request(request)
  response.header['Content-Type'] = resp.header['Content-Type']
  response.body = resp.body
end