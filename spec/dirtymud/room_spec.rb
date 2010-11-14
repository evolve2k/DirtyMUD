require 'spec_helper'

describe Dirtymud::Room do

  describe 'a room' do
    before do
      @server = mock(Dirtymud::Server).as_null_object
      @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :id => '1')
      @room2 = Dirtymud::Room.new(:description => 'Room 2', :server => @server, :id => '2')
      @player = Dirtymud::Player.new(:name => 'Dirk')

      #setup exits
      @room.exits[:n] = @room2
      @room2.exits[:s] = @room
    end

    it 'has a description' do
      @room.description.should == 'Simple room.'
    end

    it 'has players' do
      @room.players.should == []
      @room.players.push(@player)
      @room.players.should include(@player)
    end

    it 'has exits' do
      @room.exits[:n].should == @room2
      @room2.exits[:s].should == @room
      @room.exits[:e].should be_nil
    end

    describe '#enter(player)' do
      it 'moves the player into the room' do
        @player.room = @room2
        @room2.leave(@player)
        @room.enter(@player)
        @player.room.should == @room
      end

      it 'announces the player entry to the room' do
        @room.should_receive(:announce).with("#{@player.name} has entered the room.", {:except => [@player]})
        @player.room = @room2
        @room.enter(@player)
      end
    end

    describe '#leave(player)' do
      it 'announces the player departure to the room' do
        @room2.should_receive(:announce).with("#{@player.name} has left the room.", {:except => [@player]})
        @player.room = @room2
        @room2.leave(@player)
      end
    end

    describe '#announce' do
      before do
        @server = mock(Dirtymud::Server).as_null_object
        @connection1 = mock(EventMachine::Connection).as_null_object
        @connection2 = mock(EventMachine::Connection).as_null_object
        @connection3 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1)
        @player2 = @server.player_connected!(@connection2)
        @player3 = @server.player_connected!(@connection3)
        @room = Dirtymud::Room.new(:description => 'Simple room.', :server => @server, :players => [ @player1, @player2, @player3 ])
      end

      it 'calls server#announce to everyone in the room' do
        @server.should_receive(:announce).with("Important message", :only => @room.players)
        @room.announce("Important message")
      end
    end

    describe '#exits_str' do
      it 'returns the exit string for this room' do
        @room.exits_str.should == "[Exits: N]"
      end
    end

    describe '#look_str' do
      it 'returns the room description and exits' do
        @room.look_str.should == "#{@room.description}\n#{@room.exits_str}"
      end
    end
  end

end
