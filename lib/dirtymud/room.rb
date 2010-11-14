module Dirtymud
  class Room
    attr_accessor :id, :description, :players, :exits, :server, :items

    def initialize(attrs)
      @players = []
      @exits = {}
      @items = []

      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def enter(player)
      player.room = self
      players.push(player)
      # annoucne to other players that they've entered the room
      announce("#{player.name} has entered the room.", :except => [player])
    end

    def leave(player)
      players.delete(player)
      # annoucne to other players that they've left the room
      announce("#{player.name} has left the room.", :except => [player])
    end

    def announce(message, options = {})
      server.announce(message, options.merge(:only => players))
    end


    def exits_str
      dirs = exits.collect{|dir, room| dir.to_s.upcase}.join(' ')
      "[Exits: #{dirs}]"
    end

    def players_str(for_player) 
      other_players = players.reject{|p| p == for_player}
      str = "\n"
      other_players.each { |p| str << "#{p.name} is here." }
      str
   end

    def look_str(for_player)
      "#{description}\n#{exits_str}#{players_str(for_player)}"
    end

    def inspect
      "Room #{id}"
    end
  end
end
