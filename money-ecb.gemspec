Gem::Specification.new do |s|
  s.name        = 'money-ecb'
  s.version     = '0.0.2'
  s.summary     = 'Foreign exchange rates from the EU Central Bank (ECB).'
  s.description = 'A Money::Bank that will fetch foreign exchange rates from the EU Central Bank (ECB).'
  s.authors     = ['Casper Thomsen']
  s.email       = 'ct@clearhaus.com'
  s.homepage    = 'https://github.com/ct-clearhaus/money-ecb'
  s.files       = `git ls-files`.split($/)

  s.add_runtime_dependency('money', '~> 6.0.0')
  s.add_runtime_dependency('rubyzip', '>= 1.0.0')
end
