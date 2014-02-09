class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class CacheFile
        include Cache

        def initialize(path)
          @path = path
        end
        attr_reader :path

        def set(value)
          File.write(@path, value)
        end

        def get
          File.read(@path)
        end
      end
    end
  end
end
