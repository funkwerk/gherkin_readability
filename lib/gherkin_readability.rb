# encoding: utf-8
require 'gherkin/formatter/json_formatter'
require 'gherkin/parser/parser'
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
    Syllables.new(sentences.join '\n').to_h.each do |_word, syllabels|
      total_words += 1
      total_syllabels += syllabels
    end
    206.835 - 1.015 * (total_words / sentences.length) - 84.6 * (total_syllabels / total_words)
  end

  def parse(file)
    content = File.read file
    to_json(content, file)
  end

  def extract_sentences(parsed)
    feature_names = lambda do |input|
      input.map { |feature| feature['name'] unless feature['name'] == '' }
    end

    descriptions = lambda do |input|
      input.map { |feature| feature['description'] unless feature['description'] == '' }
    end

    sentences = feature_names.call(parsed) + descriptions.call(parsed) + scenario_names(parsed) + sentences(parsed)
    sentences.select! { |sentence| sentence }
    sentences.map { |sentence| sentence.gsub(/ «.+»/, '') }
  end

  def to_json(input, file = 'generated.feature')
    io = StringIO.new
    formatter = Gherkin::Formatter::JSONFormatter.new(io)
    parser = Gherkin::Parser::Parser.new(formatter, true)
    parser.parse(input, file, 0)
    formatter.done
    MultiJson.load io.string
  end

  def scenario_names(input)
    # TODO: scenario outlines with example values inside?
    scenarios = []
    input.each do |features|
      next unless features.key? 'elements'
      elements = features['elements']
      elements.each do |scenario|
        scenarios.push scenario['name'] if scenario['type'] == 'scenario'
        scenarios.push scenario['name'] if scenario['type'] == 'scenario_outline'
        scenarios.push scenario['description'] unless scenario['description'].empty?
      end
    end
    scenarios
  end

  def sentences(input)
    sentences = []
    background = []
    input.each do |features|
      next unless features.key? 'elements'
      features['elements'].each do |scenario|
        next unless scenario.key? 'steps'
        terms = background.dup
        if scenario['type'] == 'background'
          background.push extract_terms_from_scenario(scenario['steps'], terms)
          next
        end

        terms.push extract_terms_from_scenario(scenario['steps'], background)
        sentence = terms.join(' ').strip
        if scenario.key? 'examples'
          sentences += extract_examples(scenario['examples'], sentence)
        else
          sentences.push sentence
        end
      end
    end
    sentences
  end

  def extract_terms_from_scenario(steps, background)
    steps.map do |step|
      keyword = step['keyword']
      keyword = 'and ' unless background.empty? || keyword != 'Given '
      terms = [keyword, step['name']].join
      terms = uncapitalize(terms) unless background.empty?
      background = terms
      terms
    end.flatten
  end

  def extract_examples(examples, prototype)
    examples.map do |example|
      sentences = []
      sentences.push example['name'] unless example['name'].empty?
      sentences.push example['description'] unless example['description'].empty?
      sentences += expand_outlines(prototype, example)
      sentences
    end.flatten
  end

  def uncapitalize(term)
    term[0, 1].downcase + term[1..-1]
  end

  def expand_outlines(sentence, example)
    result = []
    headers = example['rows'][0]['cells']
    example['rows'].slice(1, example['rows'].length).each do |row|
      modified_sentence = sentence.dup
      headers.zip(row['cells']).map { |key, value| modified_sentence.gsub!("<#{key}>", value) }
      result.push modified_sentence
    end
    result
  end
end
