require 'spec_helper'

describe Dirtymud::Player do
  describe 'a player' do
    before do
      @server = mock(Dirtymud::Server).as_null_object
      @room_center = Dirtymud::Room.new(:description => 'Room Center', :server => @server)
      @room_n = Dirtymud::Room.new(:description => 'Room North', :server => @server)
      @room_s = Dirtymud::Room.new(:description => 'Room South', :server => @server)
      @room_e = Dirtymud::Room.new(:description => 'Room East', :server => @server)
      @room_w = Dirtymud::Room.new(:description => 'Room West', :server => @server)
      
      @connection = mock(EventMachine::Connection).as_null_object
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => @connection, :room => @room1)

      #setup room exits
      @room_w.exits = {:e => @room_center}
      @room_e.exits = {:w => @room_center}
      @room_n.exits = {:s => @room_center}
      @room_s.exits = {:n => @room_center}
      @room_center.exits = {:n => @room_n, :s => @room_s, :e => @room_e, :w => @room_w}
    end

    it 'has a name' do
      @player.name.should == 'Dirk'
    end

    it 'has a room' do
      @player.room.should == @room1
    end

    it 'has a connection' do
      @player.should respond_to(:connection)
    end
    
    it 'has items' do
      @player.items.should be_kind_of(Array)
    end

    describe '#go' do
      it 'makes an announcement on the server' do
        @player.room = @room_center
        @room_n.should_receive(:announce).with("Dirk has entered the room.", :except => [ @player ])
        @player.go('n')
      end

      it 'moves the player to the new room' do
        @player.room = @room_center
        @player.go('n')
        @player.room.should == @room_n
        @room_n.players.should include(@player)
      end

      it 'tells the player about the new room' do
        @player.room = @room_center
        @player.connection.should_receive(:write).with(@room_n.look_str)
        @player.go('n')
      end
    end

    describe '#help' do
      it 'returns the contents of world/help.txt' do
        help_contents = File.read(File.expand_path('../../../world/help.txt', __FILE__))
        @player.connection.should_receive(:write).with(help_contents)
        @player.help
      end
    end

    describe '#say(message)' do
      before do
        @server = Dirtymud::Server.new
        @connection1 = mock(EventMachine::Connection).as_null_object
        @connection2 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1, :name => 'P1')
        @player2 = @server.player_connected!(@connection2, :name => 'P2')
        @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :players => [ @player1, @player2 ])
        @player1.room = @room
        @player2.room = @room
      end

      it 'announces the message to everyone in the same room as the player' do
        @player2.connection.should_receive(:write).with("#{@player1.name} says 'hello'")
        @player1.say('hello')
      end

      it 'sends the player confirmation about what they said' do
        @player1.connection.should_receive(:write).with("You say 'hello'")
        @player1.say('hello')
      end
    end

    describe '#get(item)' do
      before do
        @server = Dirtymud::Server.new
        @connection1 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1, :name => 'P1')
        @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :players => [ @player1 ])
        @player1.room = @room
      end

      context 'when there is only one possible item match' do
        it 'takes the item from the room and adds it to the player' do
          @sword = Dirtymud::Item.new(:name => 'sword')
          @room.items << @sword
          @player1.items.should be_empty
          @player1.get('sword')
          @player1.items.should include(@sword)
        end
      end

      context 'when there are more than one possible item match' do
        it 'asks the player to be more specific' do
          @sword1 = Dirtymud::Item.new(:name => 'sword one')
          @sword2 = Dirtymud::Item.new(:name => 'sword two')
          @room.items << @sword1
          @room.items << @sword2
          @player1.items.should be_empty
          @player1.connection.should_receive(:write).with("Be more specific. Which did you want to get? 'sword one', 'sword two'")
          @player1.get('sword')
          @player1.items.should be_empty
        end
      end

      context 'when there are no matches' do
        it 'tells the player there arent any of that thing here' do
          @player1.connection.should_receive(:write).with("There's nothing here that looks like 'foo'")
          @player1.get('foo')
          @player1.items.should be_empty
        end
      end
    end

    describe '#do_command' do
      it 'handles commands for the cardinal directions' do
        #player shouldnt have trouble with the directional commands
        dirs = %w(n e s w)
        dirs.each do |dir| 
          @player.should_receive(:go).with(dir.to_s)
          @player.room = @room_center
          @player.do_command(dir)
        end

        #handles look
        @player.should_receive(:look)
        @player.do_command('look')
        
        #handles get
        @player.should_receive(:get).with('sword')
        @player.do_command('get sword')

        #handles help
        @player.should_receive(:help)
        @player.do_command('help')
      end
    end


    describe '#look' do
      it 'returns the room description and all of the people in the room' do
        server = Dirtymud::Server.new
        connection1 = mock(EventMachine::Connection).as_null_object
        connection2 = mock(EventMachine::Connection).as_null_object
        player1 = server.player_connected!(connection1, :name => 'P1')
        player2 = server.player_connected!(connection2, :name => 'P2')
        room = Dirtymud::Room.new(:description => 'Simple room.', :server => server, :players => [ player1, player2 ])
        player1.room = room
        player2.room = room

        player1.connection.should_receive(:write).with(room.look_str)
        player1.look
      end
    end

    describe '#send_data' do
      it "delegates to the player connection object" do
        @player.connection.should_receive(:write).with('foo')
        @player.send_data('foo')
      end
    end
  end
end
