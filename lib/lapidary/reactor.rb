module Lapidary
  class Reactor
    include Singleton
    include Lapidary::Misc::Logging

    attr_reader :file_system
    attr_accessor :updatemode
    attr_accessor :max_players

    def init
      @updatemode = false
      @max_players = 0x800

      @jaggrab_signature = nil
      @http_signature = nil
      @ondemand_signature = nil
      @game_signature = nil

      @log = setup_logging
    end
    def start_config(config)
      @config = config
      load_cache
      load_int_hooks
      load_defs
      load_hooks
      load_config
    end

    def reload
      HOOKS.clear
      load_hooks
      load_int_hooks
      Lapidary::Net.load_packets
    end

    def load_cache
      @file_system = Lapidary::Cache::FileSystem.new
    end

    # Load hooks
    def load_hooks
      Dir['./plugins/*.rb'].each {|file| load file }
    end
    
    def load_int_hooks
      Dir['./plugins/internal/*.rb'].each {|file| load file }
    end
    
    def load_defs
      Lapidary::Item::ItemDefinition.load
      
      # Equipment
      Lapidary::Equipment.load
    end
    
    def load_config
      WORLD.shop_manager.load_shops
      WORLD.door_manager.load_single_doors
      WORLD.door_manager.load_double_doors
      
      Lapidary::World::NPCSpawns.load
      Lapidary::World::ItemSpawns.load
    end
    
    # Runs the reactor
    def run
      EventMachine.run do
        Signal.trap('INT') { shutdown }
        Signal.trap('TERM') { shutdown }

        @jaggrab_signature = EventMachine.start_server(
          @config[:jaggrab_host],
          @config[:jaggrab_port] + Lapidary::VERSION,
          Lapidary::Cache::JaggrabConnection
        )
        @log.info "JAGGRAB (#{Lapidary::VERSION}) server listening on #{@config[:jaggrab_host]}:#{@config[:jaggrab_port] + Lapidary::VERSION}"

        @http_signature = EventMachine.start_server(
          @config[:http_host],
          @config[:http_port] + Lapidary::VERSION
        )
        @log.info "Http (#{Lapidary::VERSION}) server listening on #{@config[:http_host]}:#{@config[:http_port] + Lapidary::VERSION}"

        @ondemand_signature = EventMachine.start_server(
          @config[:ondemand_host],
          @config[:ondemand_port] + Lapidary::VERSION,
          Lapidary::Cache::OnDemandConnection
        )
        @log.info "OnDemand (#{Lapidary::VERSION}) server listening on #{@config[:ondemand_host]}:#{@config[:ondemand_port] + Lapidary::VERSION}"

        @game_signature = EventMachine.start_server(
          @config[:game_host],
          @config[:game_port] + Lapidary::VERSION,
          Lapidary::Net::Connection
        )
        @log.info "Game (#{Lapidary::VERSION}) server listening on #{@config[:game_host]}:#{@config[:game_port] + Lapidary::VERSION}"
      end
    end

    def shutdown
      @log.info 'Shutting down...'

      [
        @ondemand_signature,
        @jaggrab_signature,
        @http_signature,
        @game_signature
      ].each { |sig| EventMachine.stop_server(sig) }
      EventMachine.stop if EventMachine.reactor_running?

      WORLD.players.each {|p| WORLD.unregister(p) }

      sleep(0.01) while WORLD.work_thread.waiting.positive?
      exit
    end
  end
end
