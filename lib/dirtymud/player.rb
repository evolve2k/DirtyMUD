module Dirtymud
  class Player
    attr_accessor :name, :room, :connection

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def send_data(data)
      connection.send_data(data)
    end

    #movement
    def go(dir)
      #find out what room to go to
      if room.exits[dir.to_sym]
        self.room = room.exits[dir.to_sym]
        connection.send_data("#{room.description}\n")
        connection.send_data("You can go these ways:\n")
        room.exits.each do |k, v|
          connection.send_data("#{k}\n")
        end
      else
        connection.send_data("You can't go that way. #{room.exits.keys.join(' ')}")
      end
    end

    def help

    end

    def do_command(input)
      go(input) if input =~ /[nsew]/
    end
  end
end
