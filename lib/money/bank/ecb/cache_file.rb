class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class CacheFile < Cache
        def initialize(path = '/tmp/money-ecb-cache.csv')
          @path = path
        end

        def set(&block)
          File.open(@path, 'w') do |file|
            file.puts(yield)
          end
        end

        def get
          File.open(@path).read
        end
      end
    end
  end
end
