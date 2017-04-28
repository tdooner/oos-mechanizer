Gem::Specification.new do |s|
  s.name        = 'oos_mechanizer'
  s.version     = '0.1.1'
  s.licenses    = ['MIT']
  s.summary     = 'An interface to help navigate the Oregon Offender Search page'
  s.authors     = ['Tom Dooner']
  s.email       = 'tdooner@codeforamerica.org'
  s.files       = Dir.glob('lib/**/*.rb')
  s.add_runtime_dependency 'mechanize', '~> 2.7.5'
end

