# frozen_string_literal: true

require_relative 'ruby_file_generator'
require_relative '../prototypes/json_schema_data_types'

module Swgr2rb
  # SchemaModuleGenerator generates a Ruby module file
  # for an endpoint object model schema from its config.
  class SchemaModuleGenerator < RubyFileGenerator
    def generate_lines
      [generate_module_name,
       generate_expected_code_method,
       generate_expected_schema_method,
       'end'].compact.flatten
    end

    private

    def generate_module_name
      RubyFileGeneratorConstants::MODULE_NAME.call(@opts[:name])
    end

    def generate_expected_code_method
      RubyFileGeneratorConstants::EXPECTED_CODE.call(@config.expected_response.code)
    end

    def generate_expected_schema_method
      return unless @config.expected_response.schema.present?

      RubyFileGeneratorConstants::EXPECTED_SCHEMA.call(generate_expected_schema(@config.expected_response.schema))
    end

    def generate_expected_schema(response_schema)
      if response_schema.instance_of?(Class) || response_schema == Boolean
        response_schema.to_s.sub(/^.*::/, '')
      elsif response_schema.is_a?(Array)
        "[\n" + generate_expected_schema(response_schema.first) + "\n]"
      elsif response_schema.is_a?(Hash)
        "{\n" + generate_hash_schema(response_schema) + "\n}"
      end
    end

    def generate_hash_schema(response_schema)
      response_schema.map do |name, type|
        "#{name}: #{generate_expected_schema(type)},"
      end.join("\n").sub(/,\Z/, '')
    end
  end
end
