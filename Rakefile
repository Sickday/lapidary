require 'bundler/setup'
require 'rake'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

desc "Run the server application"
task :run do
  require 'lapidary'

  WORLD = Lapidary::World::World.new
  SERVER = Lapidary::Server.new(317)
  SERVER.start_config(Lapidary::Misc::HashWrapper.new({:port => 43594}))
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
