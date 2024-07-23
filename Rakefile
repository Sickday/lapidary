require 'bundler/setup'
require 'rake'

desc "Run the server application"
task :run do
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

  require 'lapidary'

  WORLD = Lapidary::World::World.new
  SERVER = Lapidary::Server.new
  SERVER.start_config(Lapidary::Misc::HashWrapper.new({:port => 43594}))
end
