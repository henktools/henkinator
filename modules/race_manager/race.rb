require 'chronic'

module RaceManager
  class Race
    # A unique ID for this race. Generated values will be 6-digit hexadecimals
    # to make them decently human-accessible.
    attr_accessor :id
    # The name given to this race. Used purely for display, so it does not need
    # to be unique.
    attr_accessor :name
    # The category that this race will be running in.
    attr_accessor :category
    # The time that this race will start. Stored as a DateTime, and can be
    # interpreted from a number of natural language formats.
    attr_accessor :start_time
    # An array containing the list of participants planning to take part in the
    # race. Entries should be full Discordrb::User objects.
    attr_accessor :participants
    # The users in charge of the race. Typically just one user (the creator),
    # but can be expanded to include multiple users and/or roles.
    attr_accessor :organizers
    # A boolean indicating the validity of this race object. True if the race
    # is fully well-formed after initialization.
    attr_accessor :is_valid
    alias_method :valid?, :is_valid

    def initialize name, category, start_time_string, timezone='UTC'
      # Generate a unique identifier for this race that is decently human-readable.
      self.id           = SecureRandom.hex(3)
      # Assign general race information
      self.name         = name
      self.category     = category
      # Parse the start time into a usable DateTime object. Chronic.parse will
      # return nil if the time is invalid. Since this will be used across
      # multiple timezones, a timezone can be specified as an additional
      # argument. Otherwise, UTC is implied.
      self.start_time   = Chronic.parse(start_time_string)
      # Initially, the lists of participants and organizers are empty
      self.participants = []
      self.organizers   = []
      # The validity of a race object is currently determined by the validity
      # of the start time
      self.is_valid     = self.start_time != nil
    end

    # Return a textual representation of the start time of the race as a
    # prepositional phrase, e.g. "May 31 at 12:00pm EDT(-04:00)".
    def start_time_string
      date_component = self.start_time.strftime("%b %-d")
      time_component = self.start_time.strftime("%-l:%M%P %Z(%:z)")

      "#{date_component} at #{time_component}"
    end

    # Return a textual identifier for the race, used when referring to the race
    # in messages to give users ample information to understand the race.
    def text_id
      "#{name} (##{id})"
    end
  end
end
