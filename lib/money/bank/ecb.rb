require 'rubygems'
require 'money'
require 'open-uri'
require 'bigdecimal'
require 'zip'
require 'csv'

class Money
  module Bank
    class ECBInvalidCache < StandardError; end

    class ECB < Money::Bank::VariableExchange
      RATES_URL = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref.zip'

      def initialize(cache_filename, &rounding_method)
        @cache_filename = cache_filename
        setup
      end

      attr_accessor :auto_update

      def setup
        super
        load_from_cachefile rescue update
      end

      def exchange_with(from, to, &rounding_method)
        update if @auto_update and Time.now.utc > (@rates_date + 60*60*24)
        super(from, to, &rounding_method)
      end

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

      # Load date and rates from the cache file.
      #
      # Be "loose" to accommodate for future changes in list of currencies etc.
      def load_from_cachefile
        csv = CSV.parse(File.open(@cache_filename).read, :headers => true)

        pairs = Hash[csv.first.map{|x,y| [x.strip, y.strip]}]
        pairs.delete('')
        date_s = pairs.delete('Date')

        @mutex.synchronize do
          @rates_date = Time.parse(date_s + ' 14:00:00 UTC')

          quotations = Hash[pairs.map{|cur,rate| [cur, BigDecimal.new(rate)]}]
          quotations.delete('')

          @currencies = quotations.keys

          quotations.each do |currency, rate|
            set_rate('EUR', currency, rate, :without_mutex => true)
            set_rate(currency, 'EUR', 1/rate, :without_mutex => true)

            quotations.each do |other_currency, other_rate|
              next if currency == other_currency
              set_rate(currency, other_currency, rate/other_rate, :without_mutex => true)
            end
          end
        end

        true
      end
    end
  end
end
