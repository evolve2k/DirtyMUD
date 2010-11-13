require 'spec_helper'

describe Dirtymud::Room do
  describe 'a room' do
    before do
      @room = Dirtymud::Room.new(:description => 'Simple room.')
      @room2 = Dirtymud::Room.new(:description => 'Simple room.')
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

  end
end

