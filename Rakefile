require 'bundler/setup'
require 'rake'

desc "Run the server application"
task :run do
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

  require 'calyx'

  WORLD = Calyx::World::World.new
  SERVER = Calyx::Server.new
  SERVER.start_config(Calyx::Misc::HashWrapper.new({:port => 43594}))
end