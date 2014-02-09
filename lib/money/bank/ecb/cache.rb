class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      module Cache
        # Set the cache.
        #
        # @param [String] value Set the cache to hold the value.
        # @return [String]
        def set(value)
          raise StandardError, "Implement '.set(&block)' in your Cache!"
        end

        # Get what the cache contains.
        #
        # @return [String]
        def get
          raise StandardError, "Implement '.get' in your Cache!"
        end
      end
    end
  end
end
