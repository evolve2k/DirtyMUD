module Dirtymud
  class Player
    attr_accessor :name, :room, :connection

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    #movement
    def go(dir)
      #find out what room to go to
      self.room = self.room.exits[dir.to_sym]

      self.connection.send_data(self.room.description)
    end

    def do_command(input)
      go(input) if input =~ /[nsew]/
    end
  end
end
