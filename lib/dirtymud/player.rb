module Dirtymud
  class Player
    attr_accessor :name

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end
  end
end
