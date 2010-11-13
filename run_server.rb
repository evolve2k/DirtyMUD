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
      #echo back to client
      # send_data ">>> You sent: #{data}"
      
      $server.input_received!(self, data.chomp)

      #send message to everyone else
      # World.instance.current_players.values.each do |player|
      #   player.em_client.send_data("#{@player.name} sent: " + data) #if client.object_id != self.object_id
      # end

      close_connection if data =~ /quit|exit/i
    end

    def unbind
      # World.instance.current_players.delete(@player)
    end
  end
end

$server = Dirtymud::Server.new

puts "Server running on 127.0.0.1 4000"

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 4000, Dirtymud::EventMachineServer
}

