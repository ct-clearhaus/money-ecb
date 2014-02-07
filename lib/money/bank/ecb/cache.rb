class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class Cache
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
