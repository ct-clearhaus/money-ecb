require 'rubygems'
require 'money'
require 'open-uri'
require 'zip'
require 'csv'

class Money
  module Bank
    class ECBInvalidCache < StandardError; end

    class ECB < Money::Bank::VariableExchange
      RATES_URL = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref.zip'

      class << self
        attr_accessor :ttl_days
      end

      def initialize(cache_filename, &rounding_method)
        @cache_filename = cache_filename
        setup
      end

      def setup
        super
        load_from_cachefile rescue update
      end

#     def exchange_with(&rounding_method)
#       update if
#       super() # ()'s needed?
#     end

      def update
        update_cachefile
        load_from_cachefile
      end

      attr_reader :currencies
      attr_reader :rates_date

      protected

      def update_cachefile
        File.open(@cache_filename, 'w') do |cache_file|
          Zip::InputStream.open(open(RATES_URL)) do |io|
            io.get_next_entry
            cache_file.puts(io.read)
          end
        end
      end

      def load_from_cachefile
        csv = CSV.parse(File.open(@cache_filename).read, :headers => true)

#       @mutex.synchronize do
          date_pair, *rest = csv.first.map{|x,y| [x.strip, y.strip]}
          @rates_date = date_pair[1]

          quotations = Hash[rest.map{|cur,rate| [cur, rate.to_f]}]
          quotations.delete('')

          @currencies = quotations.keys

          quotations.each do |currency, rate|
            set_rate('EUR', currency, rate)
            set_rate(currency, 'EUR', 1/rate)

            quotations.each do |other_currency, other_rate|
              next if currency == other_currency
              set_rate(currency, other_currency, rate/other_rate)
            end
          end
#       end
      end
    end
  end
end
