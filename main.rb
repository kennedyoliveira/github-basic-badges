require 'sinatra'
require 'net/http'
require 'json'

def send_request(uri, params=nil)
  uri = URI.parse(uri)

  # Extra params for custom badges
  uri.query = URI.encode_www_form(params) unless params.nil? or params.empty?

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  http.request(request)
end

#
# Generate the Badge in SVG format.
#
# @param [String] text Text to be displayed in the left said of a badge
# @param [String] status Value to be displayed in the right side of a badge
# @param [String] color Color that can be one of the following ... // TODO Document this crap
# @param [Hash] params Extra params for customizing the badge // TODO Document this crap too
# @return [String] SVG for the badge
def build_badge(text, status, color, params=nil)
  uri = "https://img.shields.io/badge/#{URI.encode(text.to_s)}-#{URI.encode(status.to_s)}-#{color}.svg"

  resp = send_request(uri, params)

  raise 'Error generating the badge' unless resp.code == '200'

  resp.body
end

# GitHub API URL
GITHUB_API = 'https://api.github.com/repos'

#
# Generate badges with download count
# Can be by tag, for the latest, summing all assets download or by a specified file name
#
get '/downloads/:user/:repo/:tag/:asset.svg' do
  text = params['text'] ||= 'downloads'
  color = params['color'] ||= 'brightgreen'

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/releases/"

  if params['tag'] == 'latest'
    git_uri += "#{params['tag']}"
  else
    git_uri += "tags/#{params['tag']}"
  end

  git_resp = send_request(git_uri)

  if git_resp.code != '200'
    status = 'vendor error'
    text = 'vendor'
    color = 'lightgray'
  else
    resp_json = JSON.parse(git_resp.body)

    if params['asset'] == 'total'
      status = resp_json['assets'].inject(0) { |total, asset| total + asset['download_count'] }
    else
      asset = resp_json['assets'].find { |asset| asset['name'] == params['asset'] }

      if asset.nil?
        text = 'vendor'
        status = 'asset not found'
        color = 'red'
      else
        status = asset['download_count']
      end
    end
  end

  badge = build_badge(text, status, color)
  response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
  response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'
  response.body = badge
end

#
# Get the last release tag name
#
get '/release/:user/:repo.svg' do
  text = params['text'] ||= 'release'
  color = params['color'] ||= 'brightgreen'

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/releases/latest"

  resp = send_request(git_uri)

  if resp.code != '200'
    text = 'vendor'
    status = 'vendor error'
    color = 'lightgray'
  else
    status = JSON.parse(resp.body)['tag_name']
  end

  badge = build_badge(text, status, color)
  response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
  response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'
  response.body = badge
end

#
# Get the issues open
#
get '/issues/:user/:repo.svg' do
  text = params['text'] ||= 'open--issues'
  color = params['color'] ||= 'red'

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}"

  resp = send_request(git_uri)

  if resp.code != '200'
    text = 'vendor'
    status = 'vendor error'
    color = 'lightgray'
  else
    status = JSON.parse(resp.body)['open_issues_count']
  end

  badge = build_badge(text, status, color)
  response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
  response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'
  response.body = badge
end

#
# Get the total commits
#
get '/commits/:user/:repo.svg' do
  # https://api.github.com/repos/kennedyoliveira/alfred-rates/stats/commit_activity
  text = params['text'] ||= 'commits'
  color = params['color'] ||= 'blue'

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/contributors"

  resp = send_request(git_uri)

  if resp.code != '200'
    text = 'vendor'
    status = 'vendor error'
    color = 'lightgray'
  else
    contributors = JSON.parse(resp.body)
    total_commits = contributors.inject(0) {|sum, contributor| sum + contributor['contributions']}

    status = total_commits
  end

  badge = build_badge(text, status, color)
  response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
  response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'
  response.body = badge
end