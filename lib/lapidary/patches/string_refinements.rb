module Lapidary::Patches::StringRefinements
  refine String do

    def ubytes; self.unpack('C*'); end

    def ibytes; self.unpack('c*'); end

    def decode_u8
      self
        .slice!(0)
        .unpack1('C')
    end

    def decode_i8
      self
        .slice!(0)
        .unpack1('c')
    end

    def decode_u16be
      self
        .slice!(0, 2)
        .unpack1('n')
    end

    def decode_u16le
      self
        .slice!(0, 2)
        .unpack1('v')
    end

    def decode_i16be
      self
        .slice!(0, 2)
        .unpack1('s>')
    end

    def decode_i16le
      self
        .slice!(0, 2)
        .unpack1('s<')
    end

    def decode_u24be
      (self.decode_u8 << 16) | self.decode_u8 << 8 | self.decode_u8 << 0
    end

    def decode_u32be
      self
        .slice!(0, 4)
        .unpack1('N')
    end

    def decode_u32le
      self
        .slice!(0, 4)
        .unpack1('V')
    end

    def decode_i32be
      self
        .slice!(0, 4)
        .unpack1('l>')
    end

    def decode_i32le
      self
        .slice!(0, 4)
        .unpack1('l<')
    end

    def decode_u64be
      self
        .slice!(0, 8)
        .unpack1('Q>')
    end

    def decode_u64le
      self
        .slice!(0, 8)
        .unpack1('Q<')
    end

    def decode_i64be
      self
        .slice!(0, 8)
        .unpack1('q>')
    end

    def decode_i64le
      self
        .slice!(0, 8)
        .unpack1('q<')
    end

    def decode_tstring
      v = String.new
      while ((c = self.slice!(0)) && c != "\n"); v << c; end
      v
    end
  end
end