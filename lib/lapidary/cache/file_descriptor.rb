module Lapidary::Cache
  class FileDescriptor
    # @return [Integer]
    attr_reader :type

    # @return [Integer]
    attr_reader :file

    def initialize(type, file)
      @type = type
      @file = file
    end
  end
end
