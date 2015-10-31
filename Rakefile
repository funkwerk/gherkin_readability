task default: :build

desc 'Builds the Gem.'
task build: :test do
  sh 'gem build gherkin_readability.gemspec'
end

task test: :format
task test: :lint
task test: :rubocop
task test: :cucumber

desc 'Publishes the Gem'
task push: :build do
  sh 'gem push gherkin_readability-0.0.1.gem'
end

desc 'Checks ruby style'
task :rubocop do
  sh 'rubocop'
end

task :cucumber do
  options = %w()
  options.push '--tags ~@slow' unless ENV['slow']
  sh "cucumber #{options * ' '}"
end

task :lint do
  sh 'gherkin_lint features/*.feature'
end

task :format do
  sh 'gherkin_format features/*.feature'
end
