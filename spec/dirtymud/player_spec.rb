require 'spec_helper'

describe Dirtymud::Player do
  describe 'a player' do
    before do
      @room_center = Dirtymud::Room.new(:description => 'Room Center')
      @room_n = Dirtymud::Room.new(:description => 'Room North')
      @room_s = Dirtymud::Room.new(:description => 'Room South')
      @room_e = Dirtymud::Room.new(:description => 'Room East')
      @room_w = Dirtymud::Room.new(:description => 'Room West')
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => EventMachine::Connection.new(nil), :room => @room1)

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
      @player.connection.should be_a_kind_of(EventMachine::Connection)
    end

    describe '#do_command' do
      it 'handles commands for the cardinal directions' do
        #player shouldnt have trouble with the directional commands
        dirs = %w(n e s w)
        dirs.each do |dir| 
          @player.connection.should_receive(:send_data).with(@room_center.exits[dir.to_sym].description)
          @player.room = @room_center
          @player.do_command(dir)
          @player.room.should == @room_center.exits[dir.to_sym]
        end
      end
    end

    describe '#send_data' do
      it "delegates to the player connection object" do
        @player.connection.should_receive(:send_data).with('foo')
        @player.send_data('foo')
      end
    end
  end
end
