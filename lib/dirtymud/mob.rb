module Dirtymud
  class Mob
    attr_accessor :id, :name

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end
  end
end
