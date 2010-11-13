require 'spec_helper'

describe Dirtymud::Player do
  describe 'a player' do
    before do
      @player = Dirtymud::Player.new(:name => 'Dirk', :connection => EventMachine::Connection.new(nil))
    end

    it 'has a name' do
      @player.name.should == 'Dirk'
    end

    it 'has a room' 

    it 'has a connection' do
      @player.connection.should be_a_kind_of(EventMachine::Connection)
    end
  end
end

