Feature: Rate
  As a Business Analyst
  I want to be informed about non readable features
  so that I know when I need to restructure

  Background:
    Given a file named "readability.rb" with:
      """
      $LOAD_PATH << '../../lib'
      require 'gherkin_readability'

      readability = GherkinReadability.new

      readability.analyze %w(default.feature test.feature)
      readability.report

      """
    And a file named "default.feature" with:
      """
      Feature: Default
        Scenario: Tag
          Given a test
          When execute
          Then pass
      """

  Scenario: Sort poor readable
    Given a file named "test.feature" with:
      """
      Feature: Unreadable busting complexity check
        Scenario: nonsense and unreadable
          Given a fancy-hyper non-readable and quite complex test specification
          When consider to execute that
          Then verification is successful
      """
    When I run `ruby readability.rb`
    Then it should pass with exactly:
      """
      119: default.feature
      30: test.feature

      """

  Scenario: Sort highly readable
    Given a file named "test.feature" with:
      """
      Feature: Test
        Scenario: Test
          When execute
          Then test
      """
    When I run `ruby readability.rb`
    Then it should pass with exactly:
      """
      120: test.feature
      119: default.feature

      """
