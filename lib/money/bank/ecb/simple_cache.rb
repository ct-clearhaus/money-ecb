class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class SimpleCache
        include Cache

        def set(value)
          @content = value
        end

        def get
          @content
        end
      end
    end
  end
end
