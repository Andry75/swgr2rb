# frozen_string_literal: true

require_relative '../../endpoint_object_models/prototypes/json_schema_data_types'

class JsonSchemaValidator
  class << self
    def validate(expected_schema, actual_schema)
      unless actual_schema.is_a? Hash
        compare_types(expected_schema, actual_schema, '')
        return
      end
      validate_keys(expected_schema.keys, actual_schema.keys)
      expected_schema.each do |key, type|
        case type
        when Hash
          validate(expected_schema[key], actual_schema[key])
        when Array
          actual_schema[key].each do |e|
            validate(expected_schema[key][0], e)
          end
        else
          compare_types(type, actual_schema[key], key)
        end
      end
    end

    private

    def compare_types(expected_type, actual_value, key)
      unless actual_value.is_a?(expected_type) || actual_value.is_a?(NilClass)
        raise "Schema do not match to the expected schema\n"\
              "key: #{key}\n"\
              "expected type: #{expected_type}\n"\
              "actual type: #{actual_value.class}"
      end
    end

    def validate_keys(expected_keys, actual_keys)
      expected_keys.sort!
      actual_keys.sort!
      unless expected_keys == actual_keys
        raise "Schema do not match to the expected schema \n\n"\
              "expected schema includes the following keys: \n"\
              "#{expected_keys.join("\n")}\n\n"\
              "actual schema includes the following keys: \n"\
              "#{actual_keys.join("\n")}\n\n"\
              "missing keys : #{(expected_keys - actual_keys).join(', ')}\n"\
              "extra keys   : #{(actual_keys - expected_keys).join(', ')}\n"
      end
    end
  end
end
