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

    describe '#go' do
      it 'should make an announcement on the server' do
        @player.room = @room_center
        @room_n.should_receive(:announce).with("Dirk has entered the room.", :except => [ @player ])
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

    describe '#do_command' do
      it 'handles commands for the cardinal directions' do
        #player shouldnt have trouble with the directional commands
        dirs = %w(n e s w)
        dirs.each do |dir| 
          @player.connection.should_receive(:write).with("#{@room_center.exits[dir.to_sym].description}\n")
          @player.connection.should_receive(:write).with("You can go these ways:\n")
          @room_center.exits[dir.to_sym].exits.each do |k, r|
            @player.connection.should_receive(:write).with("#{k}\n")
          end
          @player.room = @room_center
          @player.do_command(dir)
          @player.room.should == @room_center.exits[dir.to_sym]
        end

        #handles help
        @player.should_receive(:help)
        @player.do_command('help')
      end
    end

    describe '#say(message)' do
      it 'announces the message to everyone in the same room as the player' do
        server = Dirtymud::Server.new
        connection1 = mock(EventMachine::Connection).as_null_object
        connection2 = mock(EventMachine::Connection).as_null_object
        player1 = server.player_connected!(connection1)
        player2 = server.player_connected!(connection2)
        room = Dirtymud::Room.new(:description => 'Simple room.', :server => server, :players => [ player1, player2 ])
        player1.room = room
        player2.room = room

        player2.connection.should_receive(:write).with("#{player1.name} says 'hello'")
        player1.say('hello')
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
