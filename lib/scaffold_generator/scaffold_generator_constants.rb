# frozen_string_literal: true

module Swgr2rb
  module ScaffoldGeneratorConstants
    ENDPOINT_MODELS_DIR = 'endpoint_object_models/object_models'
    FEATURE_FILE_NAME = 'ff001_example.feature'
    FEATURES_DIR = 'features/component'
    HARNESS_DIR = 'harness'
    PATH_TO_ASSETS = '../../assets'

    FF_TAGS = proc { |component| "@component_#{component}\n@ff001" }
    FF_NAME = 'Feature: Example of JSON schema validation feature file'
    FF_SCENARIO = proc { |endpoint| "  @ff001_tc01\n  Scenario: Send get request to #{endpoint} endpoint" }
    FF_STEPS = proc do |endpoint|
      "    When I send \"get\" request to \"#{endpoint}\"\n"\
      "    Then the response schema for \"get\" request to \"#{endpoint}\" endpoint should be valid\n"
    end
  end
end
