require 'rubygems'
require 'money'
require 'open-uri'
require 'bigdecimal'
require 'zip'
require 'csv'

class Money
  module Bank
    # This class represents the European Central Bank or more precisely, its
    # foreign exchange rates.
    #
    # @!attribute [r] currencies
    #   The available currencies to exchange between.
    #   @return [Array<String>]
    #
    # @!attribute [r] rounding_method
    #   The default rounding method for the bank.
    #   @return [Proc]
    #
    # @!attribute [rw] auto_update
    #   Auto-updating on or off.
    #   @param [true,false] bool
    #   @return [true,false]
    #
    # @!attribute [r] rates_date
    #   The time on which ECB published the rates that is currently in use.
    #   @return[Time]
    class ECB < Money::Bank::VariableExchange
      # Error thrown when the cache file to be loaded isn't "good enough".
      class InvalidCacheError < StandardError; end

      RATES_URL = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref.zip'

      # Creates an Money::Bank::ECB.
      #
      # @param [String] cache_filename Absolute path and filename to the cache.
      #
      # @yield [x] Optional block to use for rounding after exchanging.
      # @yieldparam [Float] x The exchanged amount of cents to be rounded.
      # @yieldreturn [Integer]
      #
      # @return [Money::Bank::ECB]
      #
      # @example
      #   Money::Bank::ECB.new('/tmp/ecb.cache') {|x| x.floor}
      #   #=> #<Money::Bank::ECB
      #         @cache_filename='/tmp/ecb.cache',
      #         @rounding_method=#<Proc>,
      #         @auto_update=true,
      #         @rates=#<Hash>,
      #         @rates_date=#<Time>,
      #         @currencies=#<Array>>
      def initialize(cache_filename, &rounding_method)
        @cache_filename  = cache_filename
        @rounding_method = rounding_method
        setup
      end

      attr_reader :rounding_method
      attr_accessor :auto_update

      # Setup rates hash, mutex for rates locking, and auto_update default.
      #
      # @return [self]
      def setup
        @auto_update = true
        super
        reload rescue update
      end

      # Exchange some money
      #
      # @param [Money] from To exchange from.
      # @param [String,Symbol] to Currency to exchange to.
      # @yield [x] Optional block to use for rounding after exchanging.
      # @yieldparam [Float] x The exchanged amount of cents to be rounded.
      # @yieldreturn [Integer]
      #
      # @return [Money]
      #
      # @example
      #   ecb.exchange_with(Money.new(100, :EUR), :USD)
      #   #=> #<Money
      def exchange_with(from, to, &rounding_method)
        update if @auto_update and Time.now.utc > (@rates_date + 60*60*24)
        super(from, to, &rounding_method)
      end

      # Update the cache file and load the new rates.
      #
      # This is only relevant if #auto_update is false.
      #
      # @return [self]
      def update
        update_cachefile
        reload

        self
      end

      # Update the cache file.
      #
      # @return [self]
      def update_cachefile
        File.open(@cache_filename, 'w') do |cache_file|
          Zip::InputStream.open(open(RATES_URL)) do |io|
            io.get_next_entry
            cache_file.puts(io.read)
          end
        end

        self
      end

      attr_reader :currencies
      attr_reader :rates_date

      # Load rates from the cache file.
      #
      # Be "loose" to accommodate for future changes in list of currencies etc.
      #
      # @return [self]
      def reload
        date, quotations = cache_content

        @mutex.synchronize do
          @rates_date = Time.parse(date + ' ' + self.class.new_rates_time_of_day_s)
          @currencies = quotations.keys

          quotations.each do |currency, rate|
            set_rate('EUR', currency, rate, :without_mutex => true)
            set_rate(currency, 'EUR', 1/rate, :without_mutex => true)

            quotations.each do |other_currency, other_rate|
              next if currency == other_currency

              set_rate(currency, other_currency, other_rate/rate, :without_mutex => true)
            end
          end
        end

        self
      end

      private

      # Read the cache and understand it.
      #
      # @return [[Time, Hash]]
      def cache_content
        csv = CSV.parse(File.open(@cache_filename).read, :headers => true)
        csv = csv.first # Only one line.

        # Clean-up
        hash = Hash[csv.map{|x,y| [x.strip, y.strip]}]
        hash.delete('')

        date = hash.delete('Date')
        quotations = Hash[hash.map{|cur,rate| [cur, BigDecimal.new(rate)]}]

        # FIXME: Check that date and quotations are good. Otherwise, throw
        # InvalidCacheError.

        [date, quotations]
      end

      # Time of day (as a string ready for Time.parse) at which ECB publishes
      # new rates.
      #
      # @return [String] Either '13:00:00 UTC' or '14:00:00 UTC' depending on
      #   DST.
      def self.new_rates_time_of_day_s
        # FIXME: It should be off by one day!

        # 15:00 ECB local time = 14:00 UTC when CET, 13:00 UTC when CEST.
        #
        # CEST:
        # - Starts in the morning of the last Sunday in March.
        # - Ends in the morning of the last Sunday in October.
        #
        # March  ...25  26  27  28  29  30  31
        #
        #          [Su] Mo  Tu  We  Th  Fr  Sa
        #           Sa [Su] Mo  Tu  We  Th  Fr
        #           Fr  Sa [Su] Mo  Tu  We  Th
        #           Th  Fr  Sa [Su] Mo  Tu  We
        #           We  Th  Fr  Sa [Su] Mo  Tu
        #           Tu  We  Th  Fr  Sa [Su] Mo
        #           Mo  Tu  We  Th  Fr  Sa [Su]
        #
        # October...25  26  27  28  29  30  31
        #
        # Where are we relative to the Sunday-diagonal?

        now = Time.now

        on = now.day >= 25 && now.sunday?
        above =
          (now.day == 26 && [1].include?(now.wday)) ||
          (now.day == 27 && [2,1].include?(now.wday)) ||
          (now.day == 28 && [3,2,1].include?(now.wday)) ||
          (now.day == 29 && [4,3,2,1].include?(now.wday)) ||
          (now.day == 30 && [5,4,3,2,1].include?(now.wday)) ||
          (now.day == 31 && [6,5,4,3,2,1].include?(now.wday))
        below =
          (now.day == 25 && [6,5,4,3,2,1].include?(now.wday)) ||
          (now.day == 26 && [6,5,4,3,2].include?(now.wday)) ||
          (now.day == 27 && [6,5,4,3].include?(now.wday)) ||
          (now.day == 28 && [6,5,4].include?(now.wday)) ||
          (now.day == 29 && [6,5].include?(now.wday)) ||
          (now.day == 30 && [6].include?(now.wday))

        cest = (4..9).include?(now.month) ||
          (now.month ==  3 && (on || above)) ||
          (now.month == 10 && (on || below))

        cest ? '13:00:00 UTC' : '14:00:00 UTC'
      end
    end
  end
end
