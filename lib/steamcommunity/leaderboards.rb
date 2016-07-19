module SteamCommunity
  # A wrapper for steamcommunity.com's leaderboards API, available for many
  # games at:
  #   http://steamcommunity.com/stats/<app_id>/leaderboards/?xml=1
  module Leaderboards
    API_BASE = "http://steamcommunity.com/stats"

    # Return the full list of leaderboards for the given app.
    def self.all appid
      response = client.get("/#{appid}/leaderboards", xml: 1)
      response['leaderboard'] if response['leaderboardCount']
    end


    # Return a single Leaderboard instance containing information about the
    # given leaderboard for the given app. Note that the API automatically
    # truncates requests to 5000 entries.
    def self.get appid, lbid, offset: 1, limit: 10
      response = client.get("/#{appid}/leaderboards/#{lbid}",
        xml: 1,
        start: offset,
        end: offset+limit-1
      )
      response['entries']['entry'] if response['resultCount']
    end


    private

      def self.client
        @steam_client ||= SteamCommunity::Client.new API_BASE
      end
  end
end
