Gem::Specification.new do |s|
  s.name        = 'gherkin_readability'
  s.version     = '0.0.4'
  s.date        = '2016-01-17'
  s.summary     = 'Gherkin Readability'
  s.description = 'Check readability of Gherkin Files'
  s.authors     = ['Stefan Rohe']
  s.homepage    = 'http://github.com/funkwerk/gherkin_readability/'
  s.files       = `git ls-files`.split("\n")
  s.executables = s.files.grep(%r{^bin/}) { |file| File.basename(file) }
  s.add_runtime_dependency 'gherkin', ['>= 2.12.2']
  s.add_runtime_dependency 'term-ansicolor', ['>= 1.3.2']
  s.add_runtime_dependency 'syllables', ['>= 0.1.4']
  s.add_development_dependency 'aruba', ['>= 0.6.2']
end
