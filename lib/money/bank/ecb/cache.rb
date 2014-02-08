class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      module Cache
        @@classes = []
        # Use callback to store what class is including Cache.
        def self.included(cache_class)
          @@classes << cache_class
        end

        # Array of the kind of Caches that are around.
        #
        # @return [Array<Class>]
        def self.classes
          @@classes
        end

        # Tells if the arguments can be used to build such a Cache.
        #
        # @param [*]
        # @return [true,false]
        def self.new_from?(*)
          raise StandardError, "Implement '.new_from?(*args)' in your Cache!"
        end

        # Builds a Cache from some input.
        #
        # @param [*] something The thing to build a Cache from.
        # @return [Cache]
        def self.build(something)
          Cache.classes.select{|klass| klass.new_from?(something)}
            .sort_by{|klass| -klass.priority}
            .first
            .new(something)
        end

        def initialize(*)
        end

        # Set the cache to whatever the block yields.
        #
        # @yield [] block
        # @yieldreturn [String]
        def set(&block)
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
