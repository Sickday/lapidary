# A module adding overflow functions to integers to mimic the behavior of Java primitive overflow behavior.
module Lapidary::Patches::IntegerRefinements
  refine Integer do

    def encode_u8; [self].pack('C'); end

    def encode_i8; [self].pack('c'); end

    def as_ubytes; [self].pack('C*'); end

    def as_ibytes; [self].pack('c*'); end

    def encode_u16be; [self].pack('n'); end

    def encode_u16le; [self].pack('v'); end

    def encode_i16be; [self].pack('s>'); end

    def encode_i16le; [self].pack('s<'); end

    def encode_u24be; (self >> 16).encode_u8 << (self >> 8).encode_u8 << self.encode_u8; end

    def encode_u24me; (self >> 8).encode_u8 << self.encode_u8 << (self >> 16).encode_u8; end

    def encode_u24le; self.encode_u8 << (self >> 8).encode_u8 << (self >> 16).encode_u8; end

    def encode_u32be; [self].pack('N'); end

    def encode_u32le; [self].pack('V'); end

    def encode_u32me
      (self >> 8).encode_u8 << self.encode_u8 << (self >> 24).encode_u8 << (self >> 16).encode_u8
    end

    def encode_u32ime
      (self >> 16).encode_u8 << (self >> 24).encode_u8 << self.encode_u8 << (self >> 8).encode_u8
    end

    def encode_i32be; [self].pack('l>'); end

    def encode_i32le; [self].pack('l<'); end

    def encode_u64be; [self].pack('Q>'); end

    def encode_u64le; [self].pack('Q<'); end

    def encode_i64be; [self].pack('q>'); end

    def encode_i64le; [self].pack('q<'); end

    # Returns a binary representation of self as an array of 1s and 0s in their respective digits.
    # @return [Array] the binary representation
    def binary_representation
      to_s(2).chars.map(&:to_i)
    end

    alias_method :brep, :binary_representation

    # Returns a base-10 numeric from the passed array representation
    # @param representation [Array] the representation used to generate the numeric
    # @returns [Integer] the base 10 numeric of the representation.
    def from_binary_rep(representation)
      res = 0
      representation.each_with_index do |bit, idx|
        res += bit * (2**idx)
      end
      res
    end

    alias_method :from_brep, :from_binary_rep

    # Returns a string with a formatted representation of the Integer as a timestamp.
    def to_ftime
      mm, ss = divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      format('%d days, %d hours, %d minutes, and %d seconds', dd, hh, mm, ss)
    end

    alias_method :ftime, :to_ftime

    # Mutates the value according to the passed mutation
    # @param mutation [Symbol] the mutation to apply to the value.
    def mutate(mutation)
      case mutation
      when :STD then self
      when :ADD then self + 128
      when :NEG then -self
      when :SUB_PRE then 128 - self
      when :SUB_POST then self - 128
      else self.mutate(:STD)
      end
    end
  end
end