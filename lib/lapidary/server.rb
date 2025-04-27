module Lapidary
  class Server
    attr :config
    attr_accessor :updatemode
    attr_accessor :max_players
    
    def initialize(version)
      @version = version
      @updatemode = false
      @max_players = 1000
      setup_logger
    end
    
    def setup_logger
      Logging.color_scheme( 'bright',
        :levels => {
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red]
        },
        :date => :white,
        :logger => :white,
        :message => :white
      )
    
      Logging.logger.root.add_appenders(
        Logging.appenders.stdout(
          'stdout',
          :layout => Logging.layouts.pattern(
          :pattern => '[%d] %-5l %c: %m\n',
          :color_scheme => 'bright'
        )),
        Logging.appenders.file('data/logs/development.log', :layout => Logging.layouts.pattern(:pattern => '[%d] %-5l %c: %m\n'))
      )
      
      @log = Logging.logger['server']
    end
  
    def start_config(config)
      @config = config
      init_cache
      load_int_hooks
      load_defs
      load_hooks
      load_config
      bind
    end
    
    def reload
      HOOKS.clear
      load_hooks
      load_int_hooks
      Lapidary::Net.load_packets
    end
    
    # Load hooks
    def load_hooks
      Dir['./plugins/*.rb'].each {|file| load file }
    end
    
    def load_int_hooks
      Dir['./plugins/internal/*.rb'].each {|file| load file }
    end
    
    def init_cache
      begin
        $cache = Lapidary::Misc::Cache.new('./data/cache/', @version)
      rescue Exception => e
        $cache = nil
        Logging.logger['cache'].warn e.to_s
      end
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
    
    # Binds the server socket and begins accepting player connections.
    def bind
      EventMachine.run do
        Signal.trap('INT') do
          WORLD.players.each {|p| WORLD.unregister(p) }
          
          sleep(0.01) while WORLD.work_thread.waiting.positive?
          
          EventMachine.stop if EventMachine.reactor_running?
          exit
        end
        
        Signal.trap('TERM') { EventMachine.stop }
        
        EventMachine.start_server('0.0.0.0', @config.port + @version + 1, Lapidary::Net::JaggrabConnection) if $cache
        @log.info "Accepting Jaggrab on port #{@config.port + @version + 1}"

        EventMachine.start_server('0.0.0.0', @config.port + @version, Lapidary::Net::Connection)
        @log.info "Ready on port #{@config.port + @version}"
      end
    end
  end
end
