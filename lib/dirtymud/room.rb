require 'eventmachine'

module Dirtymud
  class Room
    attr_accessor :description, :players, :exits

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end
  end
end
