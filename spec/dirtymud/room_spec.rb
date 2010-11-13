require 'spec_helper'

describe Dirtymud::Room do
  describe 'a room' do
    before do
      @room = Dirtymud::Room.new(:description => 'Simple room.')
    end

    it 'has a description' do
      @room.description.should == 'Simple room.'
    end

    it 'has players' do

    end

    it 'has exits'


  end
end

