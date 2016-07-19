require 'securerandom'
require 'yaml/store'

require 'discordrb'

require './modules/race_manager/argument_parser.rb'
require './modules/race_manager/race.rb'

# A bot module for scheduling and managing race events via Discord. Acts a bit
# like a companion for SpeedRunsLive's RaceBot.
#
# TODO:
#   - Implement race management (everything)
#   - Add event handlers to move participants into a locked voice channel when
#     a race starts and kick them out afterwards. Ideally, multiple races can
#     be run concurrently, i.e. the bot should create a new channel when a race
#     starts and delete it when the race ends.
module RaceManager
  extend Discordrb::Commands::CommandContainer

  @race_store = YAML::Store.new('henkbot.race_manager')
  @parser     = ArgumentParser.new

  # Create a new race event. Returns an ID that others can use to enter.
  command :create_race do |event, *args|
    parsed_args = @parser.parse(args.join(' '), [:name, :category, :start_time, :zone])

    # Create a new race object
    new_race = Race.new parsed_args[:name], parsed_args[:category], parsed_args[:start_time]
    new_race.organizers << event.author.id

    # Only continue if the race could successfully be created.
    if new_race.valid?
      # Persist the race using it's ID as the key
      @race_store.transaction{ @race_store[new_race.id] = new_race }
      # Respond to the author with an affirmation
      event << "\"#{new_race.name}\" has been scheduled to start #{new_race.start_time_string}."
      event << "To join this race, use the command `!join_race #{new_race.id}`."
    else
      event << "Something went wrong while creating the race. Check your syntax and try again."
    end
  end

  # Delete an existing race event. Only the organizer of the race can perform
  # this action.
  # TODO: implement authorization
  command :delete_race do |event, race_id|
    @race_store.transaction do
      race = @race_store[race_id]

      if race
        @race_store.delete(race_id)
        event << "Race \"#{race.text_id}\" has been deleted."
      else
        event << "There is no race with id `#{race_id}`."
      end
    end
    nil
  end

  # Add the authoring user to the entrant list for the given race.
  command :join_race do |event, race_id|
    @race_store.transaction do
      race = @race_store[race_id]
      if race
        race.participants << event.author.id
        event << "#{event.author.name} has been added to the roster for #{race.text_id}."
      else
        event << "There is no race with id `#{race_id}`."
      end
    end
  end

  # Remove the authoring user from the entrant list for the given race.
  command :leave_race do |event, race_id|
    @race_store.transaction do
      race = @race_store[race_id]
      if race
        race.participants.delete(event.author.id)
        event << "#{event.author.name} has been removed from the roster for #{race.text_id}."
      else
        event << "There is no race with id `#{race_id}`."
      end
    end
  end


  # List all currently scheduled races.
  command :races do |event|
    event << "**The following races are currently active:**"
    @race_store.transaction do
      @race_store.roots.each_with_index do |id, idx|
        race = @race_store[id]
        event << "`##{id}`: \"#{race.name}\", _#{race.start_time_string}_"
      end
    end
    nil
  end

  # Give detailed information about the race with the given id.
  command :race_info do |event, race_id|
    @race_store.transaction do
      race = @race_store[race_id]

      if race
        event << "**Race information for #{race.text_id}:**"
        event << "Organizer: _#{event.bot.user(race.organizers.first).name}_"
        event << "Start Date: _#{race.start_time_string}_"
        event << "Category: #{race.category}"
        event << "# of Participants: #{race.participants.count}"
        event << "Join Command: `!join_race #{race.id}`"
      else
        event << "There is no race with id `#{race_id}`."
      end
    end
    nil
  end

  # Perform the preparation tasks for starting the race with the given id.
  command :prepare_race do |event, race_id|
    @race_store.transaction do
      race = @race_store[race_id]

      if race
        event.server.create_channel 'test-race-channel'
        event << "Preparation for \"#{race.name}\" is complete. The race is ready to begin and can be started using the command `!start_race #{race_id}`."
      else
        event << "There is no race with id `#{race_id}`."
      end
    end
    nil
  end


  command :start_race do |event, race_id|
  end
end
