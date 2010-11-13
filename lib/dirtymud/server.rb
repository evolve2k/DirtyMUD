module Dirtymud
  class Server
    attr_accessor :players_by_connection

    def initialize
      @players_by_connection = {}
    end

    def input_received(from_connection, input)
      @players_by_connection[from_connection].send(:do_command, input)
    end
  end
end
