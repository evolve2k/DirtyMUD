require 'spec_helper'

describe Dirtymud::Server do
  describe 'a server' do
    before do
      @server = Dirtymud::Server.new
    end

    it 'has a players_by_connection hash' do
      @server.players_by_connection.should be_kind_of(Hash)
    end

    describe '.input_received(from_connection, input)' do
      context 'when a player is connected' do
        @dirk_con = EventMachine::Connection.new(nil)
        @dirk = Dirtymud::Player.new(:name => 'Dirk', :connection => @dirk_con)

        it 'sends the command on to the player instance' do
          @dirk.should_receive(:do_command).with('n')
          @server.input_received(@dirk_con, 'n')
        end
      end
    end
  end
end


