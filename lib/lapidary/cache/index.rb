module Lapidary::Cache
  class Index
    attr_reader :size
    attr_reader :block

    def initialize(size, block)
      @size = size
      @block = block
    end

    class << self
      using Lapidary::Patches::StringRefinements

      def decode(buffer)
        buffer = buffer.ubytes
        if buffer.length != Lapidary::Cache::INDEX_SIZE
          raise "Unexpected buffer length. Buffer #{buffer.length}, Expected: #{Lapidary::Cache::INDEX_SIZE}"
        end

        size = (buffer[0] << 16) | (buffer[1] << 8) | buffer[2]
        block = (buffer[3] << 16) | (buffer[4] << 8) | buffer[5]

        Index.new(size, block)
      end
    end
  end
end
