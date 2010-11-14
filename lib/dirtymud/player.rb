module Dirtymud
  class Player
    attr_accessor :name, :room, :connection, :items

    def initialize(attrs)
      @items = []
      attrs.each do |k, v| 
        self.send("#{k}=", v)
      end
    end

    def send_data(data)
      connection.write(data)
    end

    def go(dir)
      #find out what room to go to
      if room.exits[dir.to_sym]
        # switch rooms
        room.leave(self)
        new_room = room.exits[dir.to_sym]
        new_room.enter(self)

        # send the new room look to the player
        send_data(new_room.look_str(self))
      else
        send_data("You can't go that way. #{room.exits.keys.join(' ')}")
      end
    end

    def say(message)
      room.announce("#{name} says '#{message}'", :except => [self])
      send_data("You say '#{message}'")
    end

    def get(item_text)
      #try to find an item in this room who's name contains the requested item text
      matches = room.items.select{|i| i.name =~ /#{item_text}/}

      if matches.length > 0
        if matches.length == 1
          item = matches[0]

          #give the item to the player
          items << item
          
          #remove the item from the room
          room.items.delete(item)
          
          #tell the player they got it
          send_data("You get #{item.name}")
        else
          #ask the player to be more specific
          send_data("Be more specific. Which did you want to get? #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing here by that name
        send_data("There's nothing here that looks like '#{item_text}'")
      end
    end

    def drop(item_text)
      #try to find an item in this room who's name contains the requested item text
      matches = items.select{|i| i.name =~ /#{item_text}/}

      if matches.length > 0
        if matches.length == 1
          item = matches[0]

          #drop the item to the room
          room.items << item
          
          #remove the item from the player
          items.delete(item)

          #tell the player they dropped it
          send_data("You drop #{item.name}")
        else
          #ask the player to be more specific
          send_data("Be more specific. Which did you want to drop? #{matches.collect{|i| "'#{i.name}'"}.join(', ')}")
        end
      else
        #tell the player there's nothing in their inventory by that name
        send_data("There's nothing in your inventory that looks like '#{item_text}'")
      end
    end

    def help
      help_contents = File.read(File.expand_path('../../../world/help.txt', __FILE__))
      send_data(help_contents)
    end

    def look
      send_data(room.look_str(self))
      room.players.reject{|p| p == self}.each do |p|
        send_data("#{p.name} is here.")
      end
    end

    def inventory
      str = "Your items:\n"
      if items.length > 0
        items.each { |i| str << "  - #{i.name}\n" }
      else
        str << "  (nothing in your inventory, yet...)"
      end

      send_data(str)
    end


    def do_command(input)
      case input
      when /^[nesw]$/ then go(input)
      when /^say (.+)$/ then say($1)
      when /^get (.+)$/ then get($1)
      when /^drop (.+)$/ then drop($1)
      when /^(i|inv|inventory)$/ then inventory
      when /^look$/ then look
      when /^help$/ then help
      else help
      end
    end
  end
end
