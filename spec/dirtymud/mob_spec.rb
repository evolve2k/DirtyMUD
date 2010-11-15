require 'spec_helper'

describe Dirtymud::Mob do
  describe 'a mob' do
    before do
      @mob = Dirtymud::Mob.new(:name => 'a huge spider', :id => 1)
    end
  end
end
