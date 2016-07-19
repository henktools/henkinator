# Define and expose the Steam developer key to be used in all service
# requests that require a key.
#
# Notably, the SteamCommunity API does not require a key. However, to provide
# user information, this module talks to the Steam User API, which does require
# a basic-level developer key (not necessarily a publisher key).
module SteamCommunity
  @apikey = ENV['STEAM_API_KEY']

  def self.apikey
    if @apikey.nil?
      if ENV.key?('STEAM_API_KEY')
        @apikey = ENV['STEAM_API_KEY']
      else
        fail ArgumentError, 'Steam API Key is not set.'
      end
    end
    @apikey
  end

  def api_key= key
    @apikey = key
  end
end
