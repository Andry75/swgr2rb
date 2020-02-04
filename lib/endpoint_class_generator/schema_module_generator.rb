require_relative 'file_generator'
require_relative '../prototypes/json_schema_data_types'

module Swgr2rb
  class SchemaModuleGenerator < FileGenerator
    def generate_lines
      [generate_module_name,
       generate_expected_code_method,
       generate_expected_schema_method,
       'end'].compact.flatten
    end

    private

    def generate_module_name
      FileGeneratorConstants::MODULE_NAME.call(@opts[:name])
    end

    def generate_expected_code_method
      FileGeneratorConstants::EXPECTED_CODE.call(@config.expected_response.code)
    end

    def generate_expected_schema_method
      if @config.expected_response.schema.present?
        FileGeneratorConstants::EXPECTED_SCHEMA.call(generate_expected_schema(@config.expected_response.schema))
      end
    end

    def generate_expected_schema(response_schema)
      if response_schema.instance_of?(Class) || response_schema == Boolean
        response_schema.to_s.sub(/^.*::/, '')
      elsif response_schema.is_a?(Array)
        "[\n" + generate_expected_schema(response_schema.first) + "\n]"
      elsif response_schema.is_a?(Hash)
        schema = response_schema.map { |name, type| "#{name}: #{generate_expected_schema(type)}," }
                     .join("\n").sub(/,\Z/, '')
        "{\n" + schema + "\n}"
      end
    end
  end
end
