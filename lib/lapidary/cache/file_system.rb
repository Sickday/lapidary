module Lapidary::Cache
  # The number of archives in the cache.
  # @return [Integer]
  ARCHIVE_COUNT = 0x9

  # The size of a single index
  # @return [Integer]
  INDEX_SIZE = 0x6

  # The size of a single data header
  # @return [Integer]
  HEADER_SIZE = 0x8

  # The size of a chunk of data
  # @return [Integer]
  CHUNK_SIZE = 0x200

  # The size of a single data block
  # @return [Integer]
  BLOCK_SIZE = HEADER_SIZE + CHUNK_SIZE

  class FileSystem
    using Lapidary::Patches::StringRefinements
    using Lapidary::Patches::IntegerRefinements

    # @return [Boolean]
    attr_reader :read_only

    attr_reader :indicies, :data_file, :crc_table


    def initialize(base = "data/cache/#{Lapidary::VERSION}", read_only: true)
      @read_only = read_only
      @indicies = Array.new(ARCHIVE_COUNT)
      detect_layout(base)
    end

    def get_index(file_descriptor)
      index = file_descriptor.type
      raise "Index out of bounds. (#{index})" if index.negative? || index >= @indicies.length

      buffer = ''
      idx_file = @indicies[index]
      position = file_descriptor.file * INDEX_SIZE

      if position >= 0 && (idx_file.size >= (position + INDEX_SIZE))
        idx_file.seek(position, IO::SEEK_SET)
        buffer = idx_file.read(INDEX_SIZE)
      end

      Index.decode(buffer)
    end

    def get_file_count(type)
      raise "Index out of bounds. (#{type})" if type.negative? || type >= @indicies.length

      index = @indicies[type]
      index.size / INDEX_SIZE
    end

    def get_crc_table
      raise 'Cannot read CRC table while cache in writeable mode.' unless @read_only
      return @crc_table unless @crc_table.nil?

      archives = get_file_count(0)
      hash = 1234
      crcs = Array.new(archives) { 0 }

      (1...archives).each do |i|
        file_descriptor = FileDescriptor.new(0, i)
        buffer = get_file(file_descriptor)
        crcs[i] = Zlib.crc32(buffer)
      end

      @crc_table = String.new
      crcs.each do |crc|
        hash = (hash << 1) + crc
        @crc_table << crc.encode_u32be
      end

      @crc_table << hash.encode_u32be
      @crc_table
    end

    def get_file(file_descriptor)
      index = get_index(file_descriptor)
      pointer = index.block * BLOCK_SIZE
      buffer = ''
      read = 0
      size = index.size
      blocks = size / CHUNK_SIZE
      blocks += 1 if size % CHUNK_SIZE != 0

      blocks.times do |i|
        @data_file.seek(pointer, IO::SEEK_SET)
        header = @data_file.read(HEADER_SIZE).ubytes
        pointer += HEADER_SIZE

        next_file = (header[0] << 8) | header[1]
        current_chunk = (header[2] << 8) | header[3]
        next_block = (header[4] << 16) | (header[5] << 8) | header[6]
        next_type = header[7]
        raise "Chunk id mismatch! (Current #{current_chunk}, Expected #{i})" if current_chunk != i

        chunk_size = size - read
        chunk_size = CHUNK_SIZE if chunk_size > CHUNK_SIZE

        @data_file.seek(pointer, IO::SEEK_SET)
        buffer << @data_file.read(chunk_size)

        read += chunk_size
        pointer = next_block * BLOCK_SIZE

        if size > read
          raise "Next type (#{next_type}) does not match descriptor type (#{file_descriptor.type + 1})." if next_type != file_descriptor.type + 1
          raise "Next file (#{next_file}) does not match descriptor file (#{file_descriptor.file})." if next_file != file_descriptor.file
        end
      end

      buffer
    end

    def close
      @indicies.each { |i| i.close unless i.nil? || i.closed? }
      @data_file.close
    end

    private

    def detect_layout(directory)
      index_count = 0
      indicies.length.times do |i|
        index_path = "#{directory}/main_file_cache.idx#{i}"
        if File.exist?(index_path)
          index_count += 1
          @indicies[i] = File.open(index_path, (@read_only ? 'r' : 'rw').to_s)
        end
      end

      raise "No cache index files found in #{directory}" if index_count.zero?

      if File.exist?("#{directory}/main_file_cache.dat")
        puts 'Found old engine cache data file.'
        @data_file = File.open("#{directory}/main_file_cache.dat", (@read_only ? 'r' : 'rw').to_s)
      elsif File.exist?("#{directory}/main_file_cache.dat2")
        puts 'Found new engine cache data file.'
        @data_file = File.open("#{directory}/main_file_cache.dat2", (@read_only ? 'r' : 'rw').to_s)
      else
        raise "No cache data file found in #{directory}!"
      end
    end
  end
end