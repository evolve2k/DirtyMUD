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
        room.exits[dir.to_sym].enter(self)

        # tell them about new places to go
        send_data("#{room.description}\n")
        send_data("You can go these ways:\n")
        room.exits.each do |k, v|
          send_data("#{k}\n")
        end
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
      send_data(room.description)
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
