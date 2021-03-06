Gem::Specification.new do |s|
  s.name        = 'gherkin_readability'
  s.version     = '0.2.0'
  s.date        = '2017-03-12'
  s.summary     = 'Gherkin Readability'
  s.description = 'Determine readability of Gherkin Files'
  s.authors     = ['Stefan Rohe']
  s.licenses    = ['MIT']
  s.homepage    = 'http://github.com/funkwerk/gherkin_readability/'
  s.files       = `git ls-files`.split("\n")
  s.executables = s.files.grep(%r{^bin/}) { |file| File.basename(file) }
  s.add_runtime_dependency 'gherkin', ['= 3.2.0']
  s.add_runtime_dependency 'term-ansicolor', ['>= 1.3.2']
  s.add_runtime_dependency 'syllables', ['>= 0.1.4']
  s.add_runtime_dependency 'multi_json', ['>=1.12.1']
  s.add_development_dependency 'aruba', ['>= 0.6.2']
end
