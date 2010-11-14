module Dirtymud
  class Player
    attr_accessor :name, :room, :connection

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def send_data(data)
      connection.write(data)
    end

    #movement
    def go(dir)
      #find out what room to go to
      if room.exits[dir.to_sym]
        # switch rooms
        room.leave(self)
        new_room = room.exits[dir.to_sym]
        new_room.enter(self)

        # send the new room look to the player
        send_data(new_room.look_str)
      else
        send_data("You can't go that way. #{room.exits.keys.join(' ')}")
      end
    end

    def say(message)
      room.announce("#{name} says '#{message}'", :except => [self])
    end

    def help
      help_contents = File.read(File.expand_path('../../../world/help.txt', __FILE__))
      send_data(help_contents)
    end

    def look
      send_data(room.look_str)
      room.players.reject{|p| p == self}.each do |p|
        send_data("#{p.name} is here.")
      end
    end

    def do_command(input)
      case input
      when /^[nesw]$/ then go(input)
      when /^say (.+)$/ then say($1)
      when /^look$/ then look
      when /^help$/ then help
      else help
      end
    end
  end
end
