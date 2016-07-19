# A small wrapper around the needed components of HTTParty to clean up requests
# elsewhere in the module. Specifically, all Steam APIs return a tree with a
# "response" root node that can always be stripped away.
module SteamCommunity
  class Client
    @base_uri = nil

    def initialize url
      @base_uri = url
    end

    # Wrap HTTParty.get to parse and strip away the root node of the response
    def get endpoint, wrap_name: 'response', **params
      response = HTTParty.get(@base_uri+endpoint, query: params)
      response.parsed_response[wrap_name]
    end
  end
end
