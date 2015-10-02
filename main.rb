require 'sinatra'
require 'net/http'
require 'json'

#
# Generate the Badge in SVG format.
#
# @param [String] text Text to be displayed in the left said of a badge
# @param [String] status Value to be displayed in the right side of a badge
# @param [String] color Color that can be one of the following ... // TODO Document this crap
# @param [Hash] params Extra params for customizing the badge // TODO Document this crap too
# @return [String] SVG for the badge
def build_badge(text, status, color, params=nil)
  uri = URI.parse("https://img.shields.io/badge/#{URI.encode(text.to_s)}-#{URI.encode(status.to_s)}-#{color}.svg")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  # TODO set the params for extra options

  request = Net::HTTP::Get.new(uri.request_uri)

  resp = http.request(request)

  raise 'Error generating the badge' unless resp.code == '200'

  resp.body
end

# GitHub API URL
GITHUB_API = 'https://api.github.com/repos/'

#
# Generate badges with download count
# Can be by tag, for the latest, summing all assets download or by a specified file name
#
get '/downloadcount/:user/:repo/:tag/:asset' do
  text = params['text'] ||= 'downloads'
  color = params['color'] ||= 'brightgreen'

  git_uri = URI.parse("#{GITHUB_API}/#{params['user']}/#{params['repo']}/releases/")

  if params['tag'] == 'latest'
    git_uri += "#{params['tag']}"
  else
    git_uri += "tags/#{params['tag']}"
  end

  client = Net::HTTP.new(git_uri.host, git_uri.port)
  client.use_ssl =true
  client.verify_mode = OpenSSL::SSL::VERIFY_NONE

  git_request = Net::HTTP::Get.new(git_uri.request_uri)

  git_resp = client.request(git_request)

  if git_resp.code != '200'
    status = 'vendor error'
    text = 'vendor'
    color = 'lightgray'
  else

    resp_json = JSON.parse(git_resp.body)

    if params['asset'] == 'total'
      status = resp_json['assets'].inject(0) { |total, asset| total + asset['download_count']}
    else
      asset = resp_json['assets'].find {|asset| asset['name'] == params['asset']}

      if asset.nil?
        text = 'vendor'
        status = 'asset not found'
        color = 'red'
      else
        status = asset['download_count']
      end
    end
  end

  begin
    badge = build_badge(text, status, color)
    response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
    response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.body = badge
  end
end