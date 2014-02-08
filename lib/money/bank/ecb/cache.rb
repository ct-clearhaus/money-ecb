class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      module Cache
        def initialize(*); end
        def self.new_from?(*); false end
        def self.priority; -1 end

        def set(&block); end
        def get; end

        @@classes = []
        def self.included(cache_class)
          @@classes << cache_class
        end

        def self.new_from?(_)
          raise StandardError, "Implement '.new_from?(arg)' in your Cache!"
        end

        # Builds a Cache from some input.
        #
        # @param [*] something The thing to build a Cache from.
        # @return [Cache]
        def self.build(something)
          @@classes.select{|klass| klass.new_from?(something)}
            .sort_by{|klass| -klass.priority}
            .first
            .new(something)
        end
      end
    end
  end
end
