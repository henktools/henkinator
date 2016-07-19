module SteamCommunity
  # A wrapper and caching system for Steam's profile interface, Isteamuser.
  module User
    API_BASE = "https://api.steampowered.com/Isteamuser"

    @cache = Hash.new

    # Return profile information for a user given their steam ID.
    def self.get_by_id steamid
      @cache[steamid] ||= client.get("/GetPlayerSummaries/v0002/",
        steamids: steamid,
        key: ::SteamCommunity.apikey
      )['players'].first
    end

    # Return profile information for a user given their name (vanity).
    def self.get_by_name name
      id = @cache.select{ |id, user| user.name == name }.first[1] rescue nil
      id ||= client.get("/ResolveVanityURL/v0001/",
        vanityurl: name,
        key: ::SteamCommunity.apikey
      )['steamid']
      get_by_id id
    end


    private

      def self.client
        @steam_client ||= SteamCommunity::Client.new API_BASE
      end
  end
end
