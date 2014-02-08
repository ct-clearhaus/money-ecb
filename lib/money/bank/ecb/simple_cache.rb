class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class SimpleCache
        include Cache

        def self.new_from?(*); true end
        def self.priority; 0 end

        def set(&block)
          @content = yield
        end

        def get
          @content
        end
      end
    end
  end
end
