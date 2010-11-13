require 'spec_helper'

describe Dirtymud::Player do
  describe 'a player' do
    before do
      @room1 = Dirtymud::Room.new(:description => 'Room 1')
      @room2 = Dirtymud::Room.new(:description => 'Room 2')
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => EventMachine::Connection.new(nil), :room => @room1)

      #setup room exits
      @room1.exits = {:n => @room2}
      @room2.exits = {:s => @room1}
    end

    it 'has a name' do
      @player.name.should == 'Dirk'
    end

    it 'has a room' do
      @player.room.should == @room1
    end

    it 'has a connection' do
      @player.connection.should be_a_kind_of(EventMachine::Connection)
    end

    describe '#do_command' do
      it 'handles commands for the cardinal directions' do
        @player.should be_a_kind_of(Dirtymud::Player)
        dirs = %w(n e s w)
        dirs.each {|dir| @player.do_command(dir) }
      end
    end
  end
end
