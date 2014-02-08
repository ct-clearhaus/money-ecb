class Money
  module Bank
    class ECB < Money::Bank::VariableExchange
      class CacheFile
        include Cache

        def initialize(*path)
          @path = path.first
        end
        attr_reader :path

        def self.new_from?(*path)
          path = path.first
          File.readable?(path) && File.writable?(path)
        rescue
          false
        end
        def self.priority; 1 end

        def set(&block)
          File.write(@path, yield)
        end

        def get
          File.read(@path)
        end
      end
    end
  end
end
