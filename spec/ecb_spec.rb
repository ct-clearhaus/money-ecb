require 'money/bank/ecb'

describe 'ECB' do
  before do
    @assetsdir = File.dirname(__FILE__) + '/assets'
    @tmpdir = File.dirname(__FILE__) + '/tmp'
    %x{cp -r #{@assetsdir} #{@tmpdir}}
  end

  let(:bank) do
    bank = Money::Bank::ECB.new(@tmpdir + '/good_rates.csv')
    bank.auto_update = false

    bank
  end

  after do
    %x{rm -rf #{@tmpdir}}
  end

  describe '#currencies' do
    subject(:currencies) { bank.currencies }

    it 'should have 32 currencies' do
      expect(currencies.length).to eq(32)
    end
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
      bank.currencies.each do |cur|
        sub2u = Money::Currency.wrap(cur).subunit_to_unit

        expect(fx(100, 'EUR', cur).cents).to eq((good_rates[cur]*sub2u).floor)
      end
    end

    it 'should exchange correctly to EUR' do
      bank.currencies.each do |cur|
        sub2u = Money::Currency.wrap(cur).subunit_to_unit

        factor = 1000 # To ensure non-zero values.
        expect(fx(factor*sub2u, cur, 'EUR').cents).to eq((factor*1/good_rates[cur]*100).floor)
      end
    end

    it 'should exchange correctly between non-EUR currencies'
  end

  describe '#update' do
    it 'should update rates from ECB' do
      expect(bank).to receive(:open).with(Money::Bank::ECB::RATES_URL).and_return(
        File.expand_path(@tmpdir + '/eurofxref.zip'))

      expect(bank.rates_date).to eq(Time.utc(2014, 01, 30, 14))
      bank.update
      expect(bank.rates_date).to eq(Time.utc(2014, 01, 31, 14))
    end
  end

  describe '#new' do
    context 'when cache file is good' do
      it 'should fetch use rates from cache'
    end

    context 'when cache file is bogus' do
      it 'should fetch rates from ECB'
    end
  end

  describe '#auto_update' do
    it 'should be on by default' do
      expect(Money::Bank::ECB.new(@tmpdir + '/good_rates.csv').auto_update).to be_true
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
