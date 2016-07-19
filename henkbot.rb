require 'discordrb'

require './modules/race_manager/race_manager.rb'
require './modules/steam_leaderboards/steam_leaderboards.rb'

henkbot = Discordrb::Commands::CommandBot.new(
  token: ENV['DISCORD_BOT_TOKEN'],
  application_id: ENV['DISCORD_BOT_APP_ID'],
  prefix: '!'
)

# Add the commands
henkbot.include! SteamLeaderboards
henkbot.include! RaceManager

# Start running the bot
henkbot.run


