module Dirtymud
  class Item
    attr_accessor :id, :name, :short_description, :detailed_description

    def initialize(attrs)
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

  end
end
