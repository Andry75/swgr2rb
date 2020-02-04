class JsonValidator
  class << self
    def validate(expected_schema, actual_data, expected_data = nil)
      preprocess_actual_data(actual_data).each do |data|
        JsonSchemaValidator.validate(expected_schema, data)
      end
      if expected_data
        expected = preprocess_expected_data(expected_schema, expected_data)
        JsonDataValidator.validate(expected, actual_data)
      end
    end

    private

    def preprocess_actual_data(actual_data)
      actual_data.is_a?(Array) ? actual_data : [actual_data]
    end

    def preprocess_expected_data(expected_schema, expected_data)
      case expected_data
      when Array
        expected_data.map { |data_hash| filter_expected_data_hash(expected_schema, data_hash) }
      when Hash
        filter_expected_data_hash(expected_schema, expected_data)
      else
        expected_data
      end
    end

    def filter_expected_data_hash(expected_schema, expected_data)
      expected_data.select { |key, _value| expected_schema.key?(key) }
    end
  end
end
