module RaceManager
  class ArgumentParser
    # The options that an ArgumentParser will use to parse argument strings.
    attr_accessor :options

    # The default options that an ArgumentParser will use if they are not
    # explicitly defined either via the constructor or directly setting them on
    # the options hash itself.
    DEFAULT_OPTIONS = {
      # The delimiter to use
      delimiter: ','
    }

    # Create a new ArgumentParser with the provided bare hash of options. Any
    # options that are not explicitly set will default to the values provided
    # in DEFAULT_OPTIONS.
    def initialize **opts
      @options = DEFAULT_OPTIONS.merge opts
    end

    # Parse the given argument string into an Array of arguments. If `schema`
    # is specified (as an array of names), a Hash will be returned using those
    # names as the keys.
    def parse argument_string, schema=[]
      arg_list = argument_string.split(@options[:delimiter])
      schema ? Hash[*schema.zip(arg_list).flatten] : arg_list
    end
  end
end
