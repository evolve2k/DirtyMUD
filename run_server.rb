require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'lib/dirtymud'


module Dirtymud
  module EventMachineServer
    def post_init
      #manage all connected clients
      @identifier = self.object_id

      $server.user_connected!(self)
    end

    def receive_data(data)
      $server.input_received!(self, data.chomp)

      close_connection if data =~ /quit|exit/i
    end

    def unbind
    end

    def write(data)
      send_data(data + "\n\n")
    end
  end
end

$server = Dirtymud::Server.new

puts "Server running on 127.0.0.1 4000"

EventMachine::run {
  EventMachine::start_server "0.0.0.0", 4000, Dirtymud::EventMachineServer
}

