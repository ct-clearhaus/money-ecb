require 'money/bank/ecb'
require_relative 'support/custom_expectations/write_expectation'

describe 'Money::Bank::ECB' do
  before do
    @assetsdir = File.dirname(__FILE__) + '/assets'
    @tmpdir = File.dirname(__FILE__) + '/tmp'
    %x{cp -r #{@assetsdir} #{@tmpdir}}
  end

  after do
    %x{rm -rf #{@tmpdir}}
  end

  let(:bank) do
    bank = Money::Bank::ECB.new(@tmpdir + '/good_rates.csv')
    bank.auto_update = false

    bank
  end

  describe '#new' do
    let(:good_rates) do
      {
        'USD' => 1.3574,  'JPY' => 139.28,   'BGN' => 1.9558,  'CZK' => 27.594,
        'DKK' => 7.4622,  'GBP' => 0.82380,  'HUF' => 310.97,  'LTL' => 3.4528,
        'PLN' => 4.2312,  'RON' => 4.5110,   'SEK' => 8.8347,  'CHF' => 1.2233,
        'NOK' => 8.4680,  'HRK' => 7.6605,   'RUB' => 47.8025, 'TRY' => 3.0808,
        'AUD' => 1.5459,  'BRL' => 3.2955,   'CAD' => 1.5176,  'CNY' => 8.2302,
        'HKD' => 10.5421, 'IDR' => 16551.39, 'INR' => 85.0840, 'KRW' => 1469.53,
        'MXN' => 18.1111, 'MYR' => 4.5417,   'NZD' => 1.6624,  'PHP' => 61.527,
        'SGD' => 1.7323,  'THB' => 44.745,   'ZAR' => 15.2700, 'ILS' => 4.7416,
      }
    end

    context 'when no cache is given' do
      it 'should fetch rates and store in mem' do
        expect{
          Money::Bank::ECB::RATES_URL = File.expand_path(@tmpdir + '/eurofxref.zip')
        }.to write(/warning: already initialized constant .*RATES_URL/).to(:stderr)

        bank = Money::Bank::ECB.new
        expect(bank.cache).to be_a(Money::Bank::ECB::SimpleCache)
      end
    end

    context 'when cache file path is given' do
      it 'should use the file path as a cache' do
        expect(bank.cache).to be_a(Money::Bank::ECB::CacheFile)
      end
    end

    context 'when cache file is good' do
      it 'should use rates from cache' do
        expect(bank.rates_date).to eq(Time.utc(2014, 01, 30, 14))
        bank.currencies.each do |cur|
          expect(bank.rates['EUR_TO_' + cur]).to eq(good_rates[cur])
        end
      end
    end

    context 'when cache file is bogus' do
      it 'should fetch rates from ECB' do
        expect{
          Money::Bank::ECB::RATES_URL = File.expand_path(@tmpdir + '/eurofxref.zip')
        }.to write(/warning: already initialized constant .*RATES_URL/).to(:stderr)

        bogus = Money::Bank::ECB.new(@tmpdir + '/bogus_rates.csv')
        bogus.auto_update = false

        expect(bogus.rates_date).to eq(Time.utc(2014, 01, 31, 14))
      end
    end

    context 'when a rounding method is given' do
      it 'rounding method should be used' do
        weird = Money::Bank::ECB.new(@tmpdir + '/good_rates.csv') {|x| 5}
        expect(weird.exchange_with(Money.new(100, :EUR), :USD)).to eq(Money.new(5, :USD))
      end
    end
  end

  describe '#currencies' do
    subject(:currencies) { bank.currencies }

    it 'should have 32 currencies' do
      expect(currencies.length).to eq(32)
    end

    it { expect(currencies).to include('USD', 'DKK', 'SEK', 'NOK', 'GBP') }
  end

  describe '#exchange_with' do
    let(:good_rates) do
      {
        'USD' => 1.3574,  'JPY' => 139.28,   'BGN' => 1.9558,  'CZK' => 27.594,
        'DKK' => 7.4622,  'GBP' => 0.82380,  'HUF' => 310.97,  'LTL' => 3.4528,
        'PLN' => 4.2312,  'RON' => 4.5110,   'SEK' => 8.8347,  'CHF' => 1.2233,
        'NOK' => 8.4680,  'HRK' => 7.6605,   'RUB' => 47.8025, 'TRY' => 3.0808,
        'AUD' => 1.5459,  'BRL' => 3.2955,   'CAD' => 1.5176,  'CNY' => 8.2302,
        'HKD' => 10.5421, 'IDR' => 16551.39, 'INR' => 85.0840, 'KRW' => 1469.53,
        'MXN' => 18.1111, 'MYR' => 4.5417,   'NZD' => 1.6624,  'PHP' => 61.527,
        'SGD' => 1.7323,  'THB' => 44.745,   'ZAR' => 15.2700, 'ILS' => 4.7416,
      }
    end

    def fx(cents, from, to)
      bank.exchange_with(Money.new(cents, from), to) {|x| x.floor}
    end

    it 'should exchange correctly from EUR' do
      bank.currencies.each do |to_cur|
        from_cents = 100
        to_cents = Money::Currency.wrap(to_cur).subunit_to_unit * good_rates[to_cur]

        expect(fx(from_cents, 'EUR', to_cur).cents).to eq(to_cents.floor)
      end
    end

    it 'should exchange correctly to EUR' do
      factor = 1000 # To ensure non-zero values.

      bank.currencies.each do |from_cur|
        from_cents = factor * Money::Currency.wrap(from_cur).subunit_to_unit

        rate = 1/good_rates[from_cur]
        to_cents = factor * 100 * rate

        expect(fx(from_cents, from_cur, 'EUR').cents).to eq(to_cents.floor)
      end
    end

    it 'should exchange correctly between non-EUR currencies' do
      factor = 1000 # To ensure non-zero values.

      bank.currencies.each do |from_cur|
        from_cents = factor * Money::Currency.wrap(from_cur).subunit_to_unit

        bank.currencies.each do |to_cur|
          next if from_cur == to_cur

          rate = good_rates[to_cur]/good_rates[from_cur]
          to_cents = factor * Money::Currency.wrap(to_cur).subunit_to_unit * rate

          expect(fx(from_cents, from_cur, to_cur).cents).to eq(to_cents.floor)
        end
      end
    end
  end

  describe '#update_cache and #reload' do
    it 'should update rates from ECB and should load rates from the cache file, resp.' do
      expect(bank).to receive(:open).with(Money::Bank::ECB::RATES_URL).and_return(File.expand_path(@tmpdir + '/eurofxref.zip'))

      expect(bank.rates_date).to eq(Time.utc(2014, 01, 30, 14))
      bank.update_cache
      expect(bank.rates_date).to eq(Time.utc(2014, 01, 30, 14))
      bank.reload
      expect(bank.rates_date).to eq(Time.utc(2014, 01, 31, 14))
    end
  end

  describe '#update' do
    it 'should do #update_cache and #reload' do
      expect(bank).to receive(:update_cache)
      expect(bank).to receive(:reload)

      bank.update
    end
  end

  describe '#auto_update' do
    it 'should be on by default' do
      expect(Money::Bank::ECB.new(Money::Bank::ECB::CacheFile.new(@tmpdir + '/good_rates.csv')).auto_update).to be_true
    end
  end

  describe '#cache_content' do
    context 'when cache file is good' do
      it 'should return correct date and quotations' do
        time, quotations = bank.send(:cache_content)

        expect(time).to be_a(Time)
        expect(time).to eq(Time.utc(2014, 1, 30, 14))
        expect(quotations).to be_a(Array)
        expect(quotations.map{|key,_| key}).to include('USD', 'DKK', 'JPY', 'ILS')
      end
    end

    context 'when cache file is bogus' do
      it 'should raise an InvalidCacheError' do
        expect(bank.rates_date).to eq(Time.utc(2014, 1, 30, 14))
        # Make cache bogus.
        %x{cp #{@tmpdir}/bogus_rates.csv #{@tmpdir}/good_rates.csv}

        expect{
          bank.send(:cache_content)
        }.to raise_error(Money::Bank::ECB::InvalidCacheError)
      end
    end
  end

  context 'when auto_update is on' do
    before(:each) { bank.auto_update = true }

    context 'and cache file is new enough' do
      describe '#exchange_with' do
        it 'should not update cache' do
          expect(Time).to receive(:now).and_return(bank.rates_date + 60*60*23)
          expect(bank).not_to receive(:update)
          bank.exchange_with(Money.new(100, :EUR), :USD)
        end
      end
    end

    context 'and cache file is old' do
      describe '#exchange_with' do
        it 'should update cache' do
          expect(Time).to receive(:now).and_return(bank.rates_date + 60*60*25)
          expect(bank).to receive(:update)
          bank.exchange_with(Money.new(100, :EUR), :USD)
        end
      end
    end
  end
end
