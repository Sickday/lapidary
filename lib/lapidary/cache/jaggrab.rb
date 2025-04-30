module Lapidary::Cache
  # The Jaggrab indicies
  # @return [Hash<String, Integer>] the jaggrab indicies.
  JAGGRAB_INDICIES = {
    'title' => 1,
    'config' => 2,
    'interface' => 3,
    'media' => 4,
    'versionlist' => 5,
    'textures' => 6,
    'wordenc' => 7,
    'sounds' => 8
  }.freeze

  # The Jaggrab paths
  # @return [Hash<Regex,String>] the jaggrab paths.
  JAGGRAB_PATHS = {
    /\.pack200$/ => 'runescape.pack200',
    /\.js5$/ => 'runescape.js5',
    /\.pack$/ => 'unpackclass.pack',
    /^crc/ => 'crc',
    /^config/ => 'config',
    /^title/ => 'title',
    /^interface/ => 'interface',
    /^media/ => 'media',
    /^sounds/ => 'sounds',
    /^textures/ => 'textures',
    /^versionlist/ => 'versionlist',
    /^wordenc/ => 'wordenc'
  }.freeze


  # Encapsulates a EventMachine-based JAGGRAB connection.
  class JaggrabConnection < EventMachine::Connection
    include EventMachine::Protocols::LineText2

    attr_reader :ip

    def post_init
      _, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "New JAGGRAB connection from #{@ip}"
      super
    end

    def receive_line(line)
      line = line.strip
      return unless line =~ %r{^JAGGRAB /(.*)$}

      path = fix_path(::Regexp.last_match(1))

      if path == 'crc'
        crc_table = Lapidary.reactor.file_system.get_crc_table
        send_data(crc_table)
      elsif JAGGRAB_INDICIES.include?(path)
        index = JAGGRAB_INDICIES[path]
        file_descriptor = Lapidary::Cache::FileDescriptor.new(0, index)
        send_data(Lapidary.reactor.file_system.get_file(file_descriptor))
      end
    end

    def fix_path(path)
      match = JAGGRAB_PATHS.find { |k, _| path =~ k }
      match ? match[1] : path
    end
  end
end