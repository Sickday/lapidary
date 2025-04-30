# Refinements made to the Set class of the ruby Core module.
module Lapidary::Patches::SetRefinements
  refine Set do
    # Consumes elements as they're passed to execution block.
    # @param _ [Proc] the execution block
    def each_consume(&_)
      raise 'Nil block passed to Set#each_consume.' unless block_given?

      each do |item|
        yield(item)
        delete(item)
      end
    end
  end
end


