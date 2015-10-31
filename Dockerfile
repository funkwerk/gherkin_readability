FROM ruby
MAINTAINER think@hotmail.de

RUN \
  gem install gherkin_readability --no-format-exec

CMD gherkin_readability
