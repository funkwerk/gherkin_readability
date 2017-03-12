# Check Readability of Gherkin Files

[![Build Status](https://travis-ci.org/funkwerk/gherkin_readability.svg)](https://travis-ci.org/funkwerk/gherkin_readability)
[![Docker Build](https://img.shields.io/docker/automated/gherkin/readability.svg)](https://hub.docker.com/r/gherkin/readability/)
[![Downloads](https://img.shields.io/gem/dt/gherkin_readability.svg)](https://rubygems.org/gems/gherkin_readability)
[![Latest Tag](https://img.shields.io/github/tag/funkwerk/gherkin_readability.svg)](https://rubygems.org/gems/gherkin_readability)

This tool checks the readability of gherkin files.

## Usage

run `gherkin_readability` on a list of files

    gherkin_readability FEATURE_FILES

### Usage with Docker

Assuming there are feature files in the current directory. Then call.

`docker run -ti -v $(pwd):/src -w /src gherkin/readability *.feature`

This will mount the current directory within the Gherkin Readability Docker Container and then check all feature files.
