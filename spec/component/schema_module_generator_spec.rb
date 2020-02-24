require 'rspec'
require 'swgr2rb'
require_relative '../support/endpoint_class_generator_helper'

RSpec.describe Swgr2rb::SchemaModuleGenerator, :endpoint_class_generator do
  context 'when generating expected_code' do
    it 'generates expected code correctly' do
      %w[200 201 204].each do |response_code|
        config = generate_endpoint_config(expected_response: { code: response_code })
        lines = Swgr2rb::SchemaModuleGenerator.new(config, {}).generate_lines
        expected_method = ['def expected_code',
                           response_code,
                           'end']
        expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
      end
    end
  end

  context 'when generating expected_schema' do
    it 'works correctly when there is no response body' do
      config = generate_endpoint_config(expected_response: { schema: nil })
      lines = Swgr2rb::SchemaModuleGenerator.new(config, {}).generate_lines
      expect(lines.join("\n")).not_to match(code_lines_regexp('def expected_schema'))
    end

    it 'works correctly for single-value response' do
      config = generate_endpoint_config(expected_response: { schema: String })
      lines = Swgr2rb::SchemaModuleGenerator.new(config, {}).generate_lines
      expected_method = ['def expected_schema',
                         '  String',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly for JSON response' do
      response_schema = {
        email: String,
        id: Integer,
        randomFloat: Float
      }
      config = generate_endpoint_config(expected_response: { schema: response_schema })
      lines = Swgr2rb::SchemaModuleGenerator.new(config, {}).generate_lines
      expected_method = ['def expected_schema',
                         '  {',
                         '    email: String,',
                         '    id: Integer,',
                         '    randomFloat: Float',
                         '  }',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end

    it 'works correctly for JSON response with embedded JSON' do
      response_schema = {
        status: Swgr2rb::Boolean,
        ids: [Integer],
        childJson: {
          description: String
        },
        childrenArray: [
          {
            randomFloat: Float
          }
        ]
      }
      config = generate_endpoint_config(expected_response: { schema: response_schema })
      lines = Swgr2rb::SchemaModuleGenerator.new(config, {}).generate_lines
      expected_method = ['def expected_schema',
                         '  {',
                         '    status: Boolean,',
                         '    ids: [',
                         '      Integer',
                         '    ],',
                         '    childJson: {',
                         '      description: String',
                         '    },',
                         '    childrenArray: [',
                         '      {',
                         '        randomFloat: Float',
                         '      }',
                         '    ]',
                         '  }',
                         'end']
      expect(lines.join("\n")).to match(code_lines_regexp(expected_method))
    end
  end
end
