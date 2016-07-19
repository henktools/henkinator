require 'faraday'

module SpeedrunComAPI
  API_BASE = 'https://www.speedrun.com/api/v1/'

  $conn = Faraday.new(:url => 'http://sushi.com') do |faraday|
    faraday.request  :url_encoded             # form-encode POST params
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  end
end

require './lib/speedruncom_api/leaderboard.rb'



module waitwhat
  def leaderboards game, category, limit=5
    response = _send :leaderboards, game, category, limit, embed: [:players]
    results = response["data"]
    runs = results["runs"]
    players = results["players"]["data"]

    message = "Top #{[limit, runs.count].min} runs in `#{category}`:\n"

    results["runs"].each do |entry|
      run = entry["run"]
      runner = players.find{ |p| p["id"] == run["players"].first["id"] }["names"]["international"]
      h, m, s, ms = ->(t){
        [
          t.to_i/3600 % 24,
          t.to_i/60   % 60,
          t.to_i      % 60,
          t*1000      % 1000
        ]
      }.call(run["times"]["primary_t"])
      time = "%02d:%02d:%02d.%03d" % [h, m, s, ms]
      message += "**#{entry["place"]}:** `#{time}` by **#{runner}** on #{run["date"]} (_#{run["status"]["status"]}_)\n"
    end

    message
  end
end
