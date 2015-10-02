require 'bundler'
Bundler.setup

require './badges/badges'
require 'sinatra'

# GitHub API URL
GITHUB_API = 'https://api.github.com/repos'

#
# Generate badges with download count
# Can be by tag, for the latest, summing all assets download or by a specified file name
#
get '/downloads/:user/:repo/?:tag?/:asset.svg' do
  tag = params['tag'] ||= 'latest'

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/releases/"

  if tag == 'latest'
    git_uri += "#{tag}"
  else
    git_uri += "tags/#{tag}"
  end

  custom_params = { 'text' => 'downloads', 'color' => Badges::BASIC_COLORS[:bgreen] }

  badge_request(git_uri, custom_params) do |resp|
    # If is the total, i sum the total downloads for each asset
    if params['asset'] == 'total'
      downloads = resp['assets'].inject(0) { |total, asset| total + asset['download_count'] }

      next "#{downloads} #{tag}" unless tag == 'latest'
      downloads
    else
      # Else, i try to find the asset with the name especified
      asset = resp['assets'].find { |asset| asset['name'] == params['asset'] }

      # If i doesn't find, i return an error
      next nil if asset.nil?

      "#{asset['download_count']}_#{asset['name']}"
    end
  end
end

#
# Get the last release tag name
#
get '/release/:user/:repo.svg' do
  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/releases/latest"

  custom_params = { 'text' => 'release', 'color' => Badges::BASIC_COLORS[:lgreen] }

  badge_request(git_uri, custom_params) { |resp| resp['tag_name'] }
end

#
# Get the issues open
#
get '/issues/:user/:repo.svg' do
  custom_params = { 'text' => 'open--issues', 'color' => 'red' }

  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}"

  badge_request(git_uri, custom_params) { |resp| resp['open_issues_count'] }
end

#
# Get the total commits
#
get '/commits/:user/:repo.svg' do
  git_uri = "#{GITHUB_API}/#{params['user']}/#{params['repo']}/contributors"

  custom_parameters = { 'text' => 'commits', 'color' => 'blue' }

  badge_request(git_uri, custom_parameters) { |resp| resp.inject(0) { |sum, contrib| sum + contrib['contributions'] } }
end

#
# Utility method that encapsulate the badge request logic
#
# Receives a url that will try to get, if got it succefully the body will be parsed as JSON and send to the block.
# Will merge the custom parameters for badge creating too.
#
# @param [String] url URL to be called before the block, and the response will be passed to the block if succefully
# @param [String] custom_params Custom parameters to be merged with parameters request, priorizing the parameters request, this parameters is default one for the badge request
# @param block A block that will receive the Response as json and a Hash with parameters merged, and must return a Badges::Badge instance or a single value that will be used to create a Badge
def badge_request(url, custom_params = nil, &block)
  raise 'Must pass a block for this method!' unless block_given?

  custom_params ||= {}

  # @type [Hash]
  new_params = custom_params.merge(params)

  resp = Badges::HttpUtils.get(url)

  # If failed to get GitHub valid api response, returns a vendor error badge
  return Badges.build_vendor_error_badge if resp.code != '200'

  # Call a block passing the response as a Json, and the new params for creating the Badge
  resp_badge = block.call(JSON.parse(resp.body), new_params)

  # If the blocks yields nil, then return Vendor Error
  return Badges::build_vendor_error_badge if resp_badge.nil?

  # Return the response
  response.header['Content-Type'] = 'image/svg+xml;charset=utf-8'
  response.header['Cache-Control'] = 'no-cache, no-store, must-revalidate'

  # If the return was a badge, returns this Badge
  return resp_badge if resp_badge.instance_of? Badges::Badge

  # If not a badge, create a new one
  Badges::Badge.new(new_params['text'],
                    resp_badge,
                    new_params.fetch('color', Badges::BASIC_COLORS[:bgreen]))
end
