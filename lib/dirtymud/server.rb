module Dirtymud
  class Server
    attr_accessor :players_by_connection, :rooms, :starting_room, :items

    def initialize
      @unauthed_users = {}
      @players_by_connection = {}
      @rooms = {}
      @items = {}
      load_items!
      load_rooms!
    end

    def input_received!(from_connection, input)
      #is this connection unauthed?
      if @unauthed_users.has_key?(from_connection)
        con_state = @unauthed_users[from_connection]
        if con_state[:name].nil?
          con_state[:name] = input.chomp
          from_connection.write 'Please enter your password: '
        elsif con_state[:password].nil?
          con_state[:password] = input.chomp
          #TODO: verify password at some point
          from_connection.write("Welcome, #{con_state[:name]}.\n\n")
          player = player_connected!(from_connection, :name => con_state[:name])
        end
      else
        @players_by_connection[from_connection].send(:do_command, input)
      end
    end

    def user_connected!(connection)
      @unauthed_users[connection] = {}
      connection.write 'Enter Your Character Name: '
    end

    def player_connected!(connection, params = {})
      player = Player.new(:name => params[:name], :connection => connection)
      @players_by_connection[connection] = player

      @starting_room.enter(player)
      player.send_data(@starting_room.look_str)

      @unauthed_users.delete(connection) #TODO test this

      return player
    end

    def announce(message, options = {})
      players = options.has_key?(:only) ? options[:only] : @players_by_connection.values
      players = players.reject {|p| options[:except].include?(p)} if options.has_key?(:except)

      players.each do |player|
        player.send_data("#{message}")
      end
    end

    def load_rooms!
      yaml = YAML.load_file(File.expand_path('../../../world/rooms.yml', __FILE__))['world']

      # First pass loads all the rooms
      yaml['rooms'].each do |room|
        @rooms[room['id']] = Room.new(
          :id => room['id'],
          :description => room['description'],
          :exits => {}, 
          :server => self)

        #add items to this room
        if room.has_key?('items')
          room['items'].each { |item_id| @rooms[room['id']].items << @items[item_id].clone }
        end
      end

      # Second pass creates exit-links
      yaml['rooms'].each do |room|
        room['exits'].each do |d, id|
          @rooms[room['id']].exits[d.to_sym] = @rooms[id]
        end
      end

      @starting_room = @rooms[yaml['starting_room']]
    end

    def load_items!
      items = YAML.load_file(File.expand_path('../../../world/items.yml', __FILE__))['items']
      items.each do |item|
        @items[item['id']] = Dirtymud::Item.new(:id => item['id'], :name => item['name'])
      end
    end
  end
end
