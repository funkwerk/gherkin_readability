# encoding: utf-8
gem 'gherkin', '=3.2.0'

require 'gherkin/parser'
require 'rexml/document'
require 'stringio'
require 'multi_json'
require 'term/ansicolor'
include Term::ANSIColor
require 'tmpdir'
require 'fileutils'
require 'yaml'
require 'set'
require 'digest'

# gherkin readability
class GherkinReadability
  def initialize
    @readability_by_file = {}
  end

  def analyze(files, verbose = false)
    files.each do |file|
      sentences = extract_sentences parse(file)
      sentences.each do |sentence|
        puts "#{readability([sentence]).round} - #{sentence.tr("\n", ' ').strip}"
      end if verbose
      @readability_by_file[file] = readability sentences
    end
  end

  def select_below!(threshold)
    filtered = {}
    @readability_by_file.each do |file, rating|
      filtered[file] = rating if rating <= threshold
    end
    @readability_by_file = filtered
  end

  def select_above!(threshold)
    filtered = {}
    @readability_by_file.each do |file, rating|
      filtered[file] = rating if rating >= threshold
    end
    @readability_by_file = filtered
  end

  def report
    @readability_by_file.sort { |lhs, rhs| lhs[1] <=> rhs[1] }.reverse_each do |file, rating|
      puts "#{rating.round}: #{file}"
    end
  end

  def summary
    average_readability = 0
    @readability_by_file.each do |_, rating|
      average_readability += rating
    end
    average_readability /= @readability_by_file.length
    puts "\n#{@readability_by_file.length} files analyzed. Average readability is #{average_readability.round}"
  end

  def readability(sentences)
    require 'syllables'

    total_words = 0
    total_syllabels = 0
    Syllables.new(sentences.join('\n')).to_h.each do |_word, syllabels|
      total_words += 1
      total_syllabels += syllabels
    end
    206.835 - 1.015 * (total_words / sentences.length) - 84.6 * (total_syllabels / total_words)
  end

  def parse(file)
    content = File.read file
    Gherkin::Parser.new.parse content
  end

  def extract_sentences(input)
    sentences = []

    sentences.push input[:name] unless input[:name].empty?
    sentences.push input[:description] if input.key? :description
    sentences.push input[:background][:name] if input.key?(:background) && !input[:background][:name].empty?
    sentences += scenario_names input
    sentences += sentences input
    sentences.map { |sentence| sentence.gsub(/ «.+»/, '') }
  end

  def scenario_names(input)
    scenarios = []

    input[:scenarioDefinitions].each do |scenario|
      scenarios.push scenario[:name]
      scenarios.push scenario[:description] if scenario.key? :description
    end
    scenarios
  end

  def sentences(input)
    sentences = []
    background = []

    if input.key?(:background) && input[:background].key?(:steps)
      background = extract_terms_from_scenario(input[:background][:steps], [])
    end

    input[:scenarioDefinitions].each do |scenario|
      next unless scenario.key? :steps
      terms = background.dup

      terms.push extract_terms_from_scenario(scenario[:steps], background)
      sentence = terms.join(' ').strip
      if scenario.key? :examples
        sentences += extract_examples(scenario[:examples], sentence)
      else
        sentences.push sentence
      end
    end
    sentences
  end

  def extract_terms_from_scenario(steps, background)
    steps.map do |step|
      keyword = step[:keyword]
      keyword = 'and ' unless background.empty? || keyword != 'Given '
      terms = [keyword, step[:text]].join
      terms = uncapitalize(terms) unless background.empty?
      background = terms
    end.flatten
  end

  def extract_examples(examples, prototype)
    examples.map do |example|
      sentences = []
      sentences.push example[:name] unless example[:name].empty?
      sentences.push example[:description] if example.key? :description
      sentences += expand_outlines(prototype, example)
      sentences
    end.flatten
  end

  def uncapitalize(term)
    term[0, 1].downcase + term[1..-1]
  end

  def expand_outlines(sentence, example)
    result = []
    headers = example[:tableHeader][:cells].map { |cell| cell[:value] }

    example[:tableBody].each do |row|
      modified_sentence = sentence.dup
      values = row[:cells].map { |cell| cell[:value] }
      headers.zip(values).map { |key, value| modified_sentence.gsub!("<#{key}>", value) }
      result.push modified_sentence
    end
    result
  end
end
