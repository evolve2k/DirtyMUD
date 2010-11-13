module Dirtymud
  class Server
    attr_accessor :players_by_connection

    def initialize
      @players_by_connection = {}
    end
  end
end
