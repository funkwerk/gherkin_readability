Feature: Verbose
  As a Business Analyst
  I want to read verbose output
  so that I know which scenarios are too complex

  Scenario: Verbose output
    Given a file named "readability.rb" with:
      """
      $LOAD_PATH << '../../lib'
      require 'gherkin_readability'

      readability = GherkinReadability.new

      verbose = true
      readability.analyze %w(default.feature), verbose

      """
    And a file named "default.feature" with:
      """
      Feature: Default
        Scenario: Tag
          Given a test
          When execute
          Then pass
      """
    When I run `ruby readability.rb`
    Then it should pass with:
      """
      37 - Default
      121 - Tag
      115 - Given a test when execute then pass

      """
