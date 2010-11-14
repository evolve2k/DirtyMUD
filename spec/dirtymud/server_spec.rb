require 'spec_helper'

describe Dirtymud::Server do
  describe 'a server' do
    before do
      @server = Dirtymud::Server.new
    end

    it 'has a players_by_connection hash' do
      @server.players_by_connection.should be_kind_of(Hash)
    end

    describe '.initialize' do
      it 'loads the rooms' do
        #TODO: find out how to test an that an initializer invokes some methods like #load_rooms!
      end
      it 'loads the items' do
        #TODO: find out how to test an that an initializer invokes some methods like #load_rooms!
      end
    end

    describe '.input_received!(from_connection, input)' do
      context 'when a player is connected' do
        it 'sends the command on to the player instance' do
          @dirk_con = EventMachine::Connection.new(nil)
          @dirk = Dirtymud::Player.new(:name => 'Dirk', :connection => @dirk_con)
          @server.players_by_connection[@dirk_con] = @dirk

          @dirk.should_receive(:do_command).with('n')
          @server.input_received!(@dirk_con, 'n')
        end
      end
    end

    describe '.player_connected!(connection)' do
      before do
        @dirk_con = mock(EventMachine::Connection)
      end

      it 'creates a new player, adds them to players_by_connection hash, and sends them the initial room description' do
        #REFACTOR: split these assertions into seperate expectations, if possible.
        @dirk_con.should_receive(:write).with("#{@server.starting_room.look_str}")
        @server.player_connected!(@dirk_con, :name => 'Dirk')
        @server.players_by_connection[@dirk_con].should be_kind_of(Dirtymud::Player)
      end
    end

    describe '#announce' do
      before do
        @connection1 = mock(EventMachine::Connection).as_null_object
        @connection2 = mock(EventMachine::Connection).as_null_object
        @connection3 = mock(EventMachine::Connection).as_null_object
        @player1 = @server.player_connected!(@connection1, :name => 'P1')
        @player2 = @server.player_connected!(@connection2, :name => 'P2')
        @player3 = @server.player_connected!(@connection3, :name => 'P3')
      end
      
      it 'should send a message to all connected players' do
        @connection1.should_receive(:write).with("This is very important")
        @connection2.should_receive(:write).with("This is very important")
        @server.announce("This is very important")
      end

      it 'should allow you to ignore certain players' do
        @connection1.should_not_receive(:write).with("This is very important")
        @connection2.should_receive(:write).with("This is very important")
        @server.announce("This is very important", :except => [@player1])
      end

      it 'should allow you to specify certain players' do
        msg = "This is very important"
        @connection1.should_receive(:write).with(msg)
        @connection3.should_not_receive(:write).with(msg)
        @server.announce("This is very important", :only => [@player1])
      end
    end

    describe '#load_items!' do
      it 'loads the items into the server global items hash' do
        sword = { 'id' => 1, 'name' => "a sword"}
        book = { 'id' => 2, 'name' => "a mysterious book"}
        ring = { 'id' => 3, 'name' => "a ring with a large ruby on it"}
        yaml = { 'items' => [
          sword,
          book,
          ring,
        ] }
        items_by_id = {1 => sword, 2 => book, 3 => ring}
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/items.yml', __FILE__)).and_return(yaml)
        @server.load_items!

        items_by_id.each do |id, item|
          @server.items[id].name.should == item['name']
        end
      end
    end

    describe '#load_rooms!' do
      before :each do
        items_yaml = {'items' => [
          {'id' => 1, 'name' => 'a sword'}
        ]}
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/items.yml', __FILE__)).and_return(items_yaml)
        @server.load_items!

        rooms_yaml = { 'world' => { 'starting_room' => 1, 'rooms' => [
          { 'id' => 1, 'description' => "booyah", 'exits' => { 'n' => 2 }, 'items' => [1] },
          { 'id' => 2, 'description' => "yahboo", 'exits' => { 's' => 1 } }
        ] } }
        YAML.should_receive(:load_file).with(File.expand_path('../../../world/rooms.yml', __FILE__)).and_return(rooms_yaml)
        @server.load_rooms!
      end

      it 'creates rooms with their starting items too' do
        @server.rooms[1].id.should == 1
        @server.rooms[1].description.should == 'booyah'
        @server.rooms[1].exits[:n].description.should == 'yahboo'
        @server.rooms[1].items[0].should be_kind_of(Dirtymud::Item)
        @server.rooms[1].items[0].name.should == 'a sword'
      end

      it 'sets the starting_room' do
        @server.starting_room.should == @server.rooms[1]
      end
    end
  end
end
