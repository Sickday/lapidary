require 'bundler/setup'
require 'rake'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

desc "Run the server application"
task :run do
  require 'lapidary'

  WORLD = Lapidary::World::World.new

  Lapidary.reactor.init
  Lapidary.reactor.start_config({
                                  game_host: '0.0.0.0',
                                  game_port: 43_594,
                                  jaggrab_host: '0.0.0.0',
                                  jaggrab_port: 43_595,
                                  ondemand_host: '0.0.0.0',
                                  ondemand_port: 43_596,
                                  http_host: '0.0.0.0',
                                  http_port: 8080
                                })
  Lapidary.reactor.run
end

desc "Load 317 RS Cache"
task :load_317 do
  require 'lapidary'
  
  $cache = Lapidary::Misc::Cache.new("./data/cache/317/")
rescue StandardError => e
    $cache = nil
    puts e.to_s
end

desc "Load 377 RS Cache"
task :load_377 do
  require 'lapidary'
  
  $cache = Lapidary::Misc::Cache.new("./data/cache/377/")
rescue StandardError => e
  $cache = nil
  puts e.to_s
end
