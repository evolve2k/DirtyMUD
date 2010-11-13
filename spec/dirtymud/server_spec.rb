require 'spec_helper'

describe Dirtymud::Server do
  describe 'a server' do
    before do
      @server = Dirtymud::Server.new
    end

    it 'has a players_by_connection hash' do
      @server.players_by_connection.should be_kind_of(Hash)
    end

    describe '.parse_input' do
      context 'when a player is connected' do
        @dirk_con = EventMachine::Connection.new(nil)
        @dirk = Dirtymud::Player.new(:name => 'Dirk', :connection => @dirk_con)

        
      end
    end
  end
end


