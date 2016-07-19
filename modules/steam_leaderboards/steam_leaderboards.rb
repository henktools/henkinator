require 'discordrb'
require 'steamcommunity'

module SteamLeaderboards
  extend Discordrb::Commands::CommandContainer

  attrs = {
    description: 'Return the top times for a level. Forces an update of the local cache.',
    usage: '!top <count> <level_name>',
    min_args: 2
  }
  command :top, attrs do |event, count=5, *level|
    level_name = level.join(' ')
    actual_name = HenkLevels.actual_name_for_alias level_name
    level_id = HenkLevels.id_for_name actual_name
    board = SteamCommunity::Leaderboards.get 285820, level_id, limit: count.to_i, offset: 1

    event << "**Top #{count} times for '#{actual_name}':**"
    board.each do |entry|
      response = SteamCommunity::User.get_by_id entry['steamid']
      user_name = response['personaname']
      time = Time.at(entry['score'].to_f / 1000)
      event << "**#{entry['rank']}:** `#{time.strftime('%_2M:%02S.%03L')}` by _#{user_name}_"
    end
    nil
  end


  attrs = {
    description: 'Return the rank and time for a player on a given level. Does not force an update of the local cache.',
    usage: '!rank <player_name> <level_name>',
    min_args: 2
  }
  command :rank, attrs do |event, name, *level|
    level_name = level.join(' ')
    actual_name = HenkLevels.actual_name_for_alias level_name
    level_id = HenkLevels.id_for_name actual_name
    board = SteamCommunity::Leaderboards.get 285820, level_id, limit: 1000, offset: 1
    user = SteamCommunity::User.get_by_name name
    user_name = user['personaname']

    your_entry = board.find{ |e| e['steamid'] == user['steamid'] }
    time = Time.at(your_entry['score'].to_f / 1000)

    event << "_#{user_name}_ is rank **#{your_entry['rank']}** on '#{actual_name}' with a `#{time.strftime('%_2M:%02S.%03L')}`"
    nil
  end
end
