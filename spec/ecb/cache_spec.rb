require 'securerandom'
require 'tempfile'

describe 'Money::Bank::ECB::SimpleCache' do
  it 'should respect the set/get interface' do
    c = Money::Bank::ECB::SimpleCache.new
    random = SecureRandom.urlsafe_base64(10)

    expect(c.set(random)).to eq(random)
    expect(c.get).to eq(random)
  end
end

describe 'Money::Bank::ECB::CacheFile' do
  it 'should respect the set/get interface' do
    c = Money::Bank::ECB::CacheFile.new(Tempfile.new('money-ecb-spec').path)
    random = SecureRandom.urlsafe_base64(10)

    expect(c.set(random)).to eq(random)
    expect(c.get).to eq(random)
  end
end
