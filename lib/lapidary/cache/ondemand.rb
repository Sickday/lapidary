module Lapidary::Cache
  class OnDemandConnection < EventMachine::Connection
    using Lapidary::Patches::StringRefinements
    using Lapidary::Patches::IntegerRefinements

    attr_reader :ip

    def post_init
      _, @ip = Socket.unpack_sockaddr_in(get_peername)
      @acknowledged = false
      puts "(#{@ip}) New OnDemand connection."
      super
    end

    def receive_data(data)
      if @acknowledged
        process_ondemand(data)
      else
        request_type = data.decode_u8
        if request_type == 15
          puts "(#{@ip}) Accepting OnDemand requests"
          send_data 0.encode_u64be
          @acknowledged = true
        else
          puts "(#{@ip}) Unknown session request. Disconnecting."
          close_connection
        end
      end
    rescue StandardError => e
      puts "(#{@ip}) encountered an error while decoding ondemand request: #{e.message}", e.backtrace[0..1].join("\n")
    end

    private

    def process_ondemand(buffer)
      cache_id = buffer.decode_u8
      file_id = buffer.decode_u16be
      _priority = buffer.decode_u8

      file_descriptor = Lapidary::Cache::FileDescriptor.new(cache_id + 1, file_id)
      data = Lapidary.reactor.file_system.get_file(file_descriptor)
      total_size = data.size
      rounded_size = total_size
      rounded_size += 1 while rounded_size % 500 != 0
      blocks = rounded_size / 500
      sent_bytes = 0

      blocks.times do |i|
        block_size = total_size - sent_bytes
        block_size = 500 if block_size > 500

        buff = String.new
        buff << cache_id.encode_u8
        buff << file_id.encode_u16be
        buff << total_size.encode_u16be
        buff << i.encode_u8
        buff << data.slice(sent_bytes, block_size)

        sent_bytes += block_size
        send_data(buff)
      end
    end
  end
end