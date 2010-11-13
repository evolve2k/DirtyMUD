module Dirtymud
  class Server
    attr_accessor :players_by_connection, :rooms, :starting_room

    def initialize
      @players_by_connection = {}
      @rooms = {}
    end

    def input_received(from_connection, input)
      @players_by_connection[from_connection].send(:do_command, input)
    end

    def load_rooms
      yaml = YAML.load_file(File.expand_path('../../../world/rooms.yml', __FILE__))['world']
      # First pass loads all the rooms
      yaml['rooms'].each do |room|
        @rooms[room['id']] = Room.new(:id => room['id'], :description => room['description'], :exits => {})
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
