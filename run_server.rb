require 'rubygems'
require 'bundler/setup'
require 'eventmachine'


module Dirtymud
  module Server
    def post_init
      #manage all connected clients
      @identifier = self.object_id

      # @player = Player.new({:current_room => $world.rooms.first[1], :name => 'Player ' + $world.current_players.length.to_s, :em_client => self})
      # $world.current_players[@player.name] = @player
    end

    def receive_data(data)
      #echo back to client
      send_data ">>> You sent: #{data}"
      # @player.handle_command(data)

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


EventMachine::run {
  EventMachine::start_server "127.0.0.1", 4000, Dirtymud::Server
}
