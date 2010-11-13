module Dirtymud
  class Server
    attr_accessor :players_by_connection, :rooms

    def initialize
      @players_by_connection = {}
      @rooms = {}
      load_rooms!
    end

    def input_received!(from_connection, input)
      @players_by_connection[from_connection].send(:do_command, input)
    end

    def player_connected!(connection)
      player = Player.new(:name => 'Player ' + connection.object_id.to_s, :connection => connection)
      @players_by_connection[connection] = player

      #TODO: drop player in the default room
      player.room = @rooms['1']
    end

    def load_rooms!
      yaml = YAML.load_file(File.expand_path('../../../world/rooms.yml', __FILE__))['world']['rooms']
      # First pass loads all the rooms
      yaml.each do |room|
        @rooms[room['id']] = Room.new(:id => room['id'], :description => room['description'], :exits => {})
      end
      # Second pass creates exit-links
      yaml.each do |room|
        room['exits'].each do |d, id|
          @rooms[room['id']].exits[d.to_sym] = @rooms[id]
        end
      end
    end
  end
end
