module Dirtymud
  class Server
    attr_accessor :players_by_connection, :rooms, :starting_room

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

      @starting_room.enter(player)
      player.connection.send_data("#{player.room.description}\n")

      return player
    end

    def announce(message, options = {})
      players = options.has_key?(:only) ? [*options[:only]] : @players_by_connection.values
      players.each do |player|
        if !options[:except] || (options[:except] && player != options[:except])
          player.connection.send_data("#{message}\n")
        end
      end
    end

    def load_rooms!
      yaml = YAML.load_file(File.expand_path('../../../world/rooms.yml', __FILE__))['world']
      # First pass loads all the rooms
      yaml['rooms'].each do |room|
        @rooms[room['id']] = Room.new(:id => room['id'], :description => room['description'], :exits => {}, :server => self)
      end
      # Second pass creates exit-links
      yaml['rooms'].each do |room|
        room['exits'].each do |d, id|
          @rooms[room['id']].exits[d.to_sym] = @rooms[id]
        end
      end
      @starting_room = @rooms[yaml['starting_room']]
    end
  end
end
