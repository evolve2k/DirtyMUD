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

    end

    def do_command(input)
      go(input) if input =~ /[nsew]/
    end
  end
end
