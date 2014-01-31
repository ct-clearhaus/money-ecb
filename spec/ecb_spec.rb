require 'money'
require 'money/bank/ecb'

describe 'ECB' do
# describe '#currencies' do
#   subject(:currencies) do
#     assetsdir = File.dirname(__FILE__) + '/assets'
#     bank = Money::Bank::ECB.new(assetsdir + '/good_rates.csv')

#     bank.currencies
#   end

#   it 'should give 32 currencies' do
#     expect(currencies.length).to eq(32)
#   end
# end

# describe '#update' do
# end

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

    let(:bank) do
      assetsdir = File.dirname(__FILE__) + '/assets'
      Money::Bank::ECB.new(assetsdir + '/good_rates.csv')
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
  end

# describe 'Cache expiring' do
# end
end
