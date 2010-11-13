require 'spec_helper'

describe Dirtymud::Player do
  describe 'a player' do
    before do
      @player = Dirtymud::Player.new(:name => 'Dirk')
    end

    it 'has a name' do
      @player.name.should == 'Dirk'
    end
  end
end

