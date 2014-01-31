Gem::Specification.new do |s|
  s.name    = 'money-ecb'
  s.version = '0.0.1'
  s.summary = 'Fetch foreign exchange rates from the EU Central Bank (ECB) to use with Money gem.'
  s.authors = ['Casper Thomsen']
  s.files   = `git ls-files`.split($/)

  s.add_runtime_dependency('money', '~> 6.0.0')
  s.add_runtime_dependency('rubyzip', '>= 1.0.0')
end
